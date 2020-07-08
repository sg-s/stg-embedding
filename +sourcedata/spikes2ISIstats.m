% converts ISIs to summary statistics in a semi-designed way
% mean to replace spiketimes2percentiles
% 
function [V,M] = spikes2ISIstats(alldata)

DataSize = length(alldata.mask);



% clean up spikes -- remove first spike time from each set
offset = (nanmin([alldata.PD alldata.LP],[],2));
for i = 1:DataSize
	if ~isnan(offset(i))
		alldata.PD(i,:) = alldata.PD(i,:) - offset(i);
		alldata.LP(i,:) = alldata.LP(i,:) - offset(i);
	end
end



% construct the 2nd order ISIs
neurons = {'PD','LP'};
for i = 1:length(neurons)


	alldata.([neurons{i} '_' neurons{i} '2']) = NaN(DataSize,1e3);

	for j = 1:DataSize
		spikes = alldata.(neurons{i})(j,:);

		% check if there is a large empty section
		maxisi = max(diff(spikes));
		if (20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes)))) > maxisi
			spikes(find(isnan(spikes),1,'first')) = max(spikes)+(20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes))));
		end


		spikes2 = circshift(spikes,2);

		isis = spikes-spikes2;
		isis(isis<0.001) = NaN;
		alldata.([neurons{i} '_' neurons{i} '2'])(j,:) = isis;

		
	end
end


isi_types = {'PD_PD','LP_LP','PD_PD2','LP_LP2'};
M = struct;

%for i = 3
for i = length(isi_types):-1:1

	disp(isi_types{i})

	neuron = isi_types{i};
	z = strfind(neuron,'_');
	neuron = neuron(1:z-1);


	isis = alldata.(isi_types{i});
	spikes = alldata.(neuron);

	% minimum ISI
	% minimum dominated by nonsense, so ignore everyhting below a thresh
	temp = nanmin(isis,[],2);
	temp(temp<.01) = -1; % -1 is the "undefined" flag
	%M(i).Minimum = temp;


	Maximum = nanmax(isis,[],2);
	%M(i).Median = nanmedian(X,2);

	M(i).DominantPeriod = NaN*Maximum;
	%M(i).NormPeriodRange = NaN*Maximum;
	M(i).DomPeriodLessThanMax = zeros(size(isis,1),1)-1;
	%M(i).FailureMode = zeros(size(isis,1),6);
	


	% compute dominant period from ISIs
	[metrics] = sourcedata.ISI2DominantPeriod(spikes, isis);
	M(i).DominantPeriod = metrics.DominantPeriod;
	M(i).T_mismatch = metrics.T_mismatch;
	if i < 3
		M(i).NSpikesVar = metrics.NSpikesVar;
		M(i).NSpikesMean = metrics.NSpikesMean;
	end


	
	% convert failure mode to one-hot encoding
	% for j= 1:length(fm)
	% 	if fm(j) == 0
	% 		continue
	% 	end
	% 	M(i).FailureMode(j,fm(j)) = 1;
	% end


	% M(i).NormPeriodRange = M(i).NormPeriodRange*10;


	% capture irregularity 
	% very negative values here indicate irregularity 
	temp = M(i).DominantPeriod - Maximum;
	temp(M(i).DominantPeriod<0 | isnan(Maximum)) = NaN;
	M(i).DomPeriodLessThanMax(temp < 0) = 10;
	M(i).DomPeriodLessThanMax(temp > 0) = 0;

	Maximum(isnan(Maximum)) = 20;
	M(i).Maximum = Maximum;



	% capture "burstiness"
	% M(i).MaxMin = Maximum - M(i).Minimum;
	%M(i).MaxMedian = Maximum - M(i).Median;



end

V = struct2array(M);
V(isnan(V)) = -1;


% delete columns with zero information
% because some columns are not defined, and are just dummy data
V(:,std(V)==0) = [];

% also add something that scales with the inverse firing rate (so in units of time)
V2 = [20./sum(~isnan(alldata.PD),2) 20./sum(~isnan(alldata.LP),2)];
V2(isinf(V2)) = -1;
V2(isnan(V2)) = -1;


% add metrics of delays
delays1 = prctile(alldata.LP_PD',[0 25 50 75 100])';
delays2 =  prctile(alldata.PD_LP',[0 25 50 75 100])';
delay_var1 = (max(delays1,[],2)-min(delays1,[],2))./nanmean(delays1,2);
delay_var2 = (max(delays2,[],2)-min(delays2,[],2))./nanmean(delays2,2);
delay_var2(isnan(delay_var2)) = 10;
delay_var1(isnan(delay_var1)) = 10;
delays = [delays1 delays2 delay_var1 delay_var2];

delays(isnan(delays)) = -1;


% also measure the maximum time without a spike
% PD = data.PD;
% LP = data.LP;
% for i = 1:size(PD,1)
% 	PD(i,:) = PD(i,:) - min(PD(i,:));
% 	LP(i,:) = LP(i,:) - min(LP(i,:));
% end
% MaxNoPD = 20 - max(PD,[],2); MaxNoPD(isnan(MaxNoPD)) = 20;
% MaxNoLP = 20 - max(LP,[],2); MaxNoLP(isnan(MaxNoLP)) = 20;


% penalize neuron T mismatch
NeuronMismatch = abs(log([M(1).DominantPeriod./M(2).DominantPeriod]));
NeuronMismatch(NeuronMismatch>log(1.5)) = 10; 
NeuronMismatch(M(1).DominantPeriod < 0 ) = 10;
NeuronMismatch(M(2).DominantPeriod < 0 ) = 10;

% penalize sudden increases in higher-order ISI maxima --
% indicative of weak bursts
WeakPD = 10*erf((M(3).Maximum./M(1).Maximum)-1);
WeakPD(M(3).Maximum == 20) = 10;
WeakPD(M(1).Maximum == 20) = 10;

WeakLP = 10*erf((M(4).Maximum./M(2).Maximum)-1);
WeakLP(M(4).Maximum == 20) = 10;
WeakLP(M(2).Maximum == 20) = 10;

V = [V V2 delays NeuronMismatch WeakPD WeakLP];

