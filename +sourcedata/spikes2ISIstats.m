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
	% minimum dominated by nonsense, so ignore everything below a thresh
	temp = nanmin(isis,[],2);
	temp(temp<.01) = -1; % -1 is the "undefined" flag
	%M(i).Minimum = temp;


	Maximum = nanmax(isis,[],2);
	%M(i).Median = nanmedian(X,2);

	%M(i).NormPeriodRange = NaN*Maximum;
	M(i).DomPeriodLessThanMax = zeros(size(isis,1),1)+10;
	M(i).DomPeriodMuchMoreThanMax = zeros(size(isis,1),1)+10;


	% compute dominant period from ISIs
	[metrics] = sourcedata.ISI2DominantPeriod(spikes, isis);
	M(i).DominantPeriod = metrics.DominantPeriod;
	M(i).T_mismatch = metrics.T_mismatch;
	M(i).NormPeriodRange = metrics.NormPeriodRange;

	if i < 3
		M(i).NSpikesVar = metrics.NSpikesVar;
		M(i).NSpikesMean = metrics.NSpikesMean;
	end




	


	% capture irregularity 
	% very negative values here indicate irregularity 
	temp = M(i).DominantPeriod - Maximum;
	temp(M(i).DominantPeriod == 20 | isnan(Maximum)) = NaN;
	M(i).DomPeriodLessThanMax(temp < 0) = 10;
	M(i).DomPeriodLessThanMax(temp > 0) = 0;

	temp = M(i).DominantPeriod -  2*Maximum;
	temp(M(i).DominantPeriod == 20 | isnan(Maximum)) = NaN;
	M(i).DomPeriodMuchMoreThanMax(temp > 0) = 10;
	M(i).DomPeriodMuchMoreThanMax(temp < 0) = 0;

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
V2(isinf(V2)) = 20;


% add metrics of delays
SyncLP = 1./nanmin(alldata.LP_PD,[],2);
SyncPD = 1./nanmin(alldata.PD_LP,[],2);
SyncLP(SyncLP<(1/50e-3)) = 0;
SyncPD(SyncPD<(1/50e-3)) = 0;
SyncLP = 10*SyncLP./nanmax(SyncLP);
SyncPD = 10*SyncPD./nanmax(SyncPD);
SyncLP(isnan(SyncLP)) = 10;
SyncPD(isnan(SyncPD)) = 10;

PDphase = (nanmean(alldata.LP_PD,2)./M(1).DominantPeriod);
LPphase = (nanmean(alldata.PD_LP,2)./M(2).DominantPeriod);
PDphase(M(1).DominantPeriod == 20) = -1;
LPphase(M(2).DominantPeriod == 20) = -1;
PDphase(isnan(PDphase)) = -1;
LPphase(isnan(LPphase)) = -1;

% scale
PDphase = PDphase*10;
LPphase = LPphase*10;

% penalize neuron T mismatch
NeuronMismatch = abs(log([M(1).DominantPeriod./M(2).DominantPeriod]));
NeuronMismatch(NeuronMismatch>log(1.5)) = 10; 
NeuronMismatch(M(1).DominantPeriod == 20 ) = 10;
NeuronMismatch(M(2).DominantPeriod == 20 ) = 10;

% penalize sudden increases in higher-order ISI maxima --
% indicative of weak bursts
WeakPD = 10*erf((M(3).Maximum./M(1).Maximum)-1);
WeakPD(M(3).Maximum == 20) = 10;
WeakPD(M(1).Maximum == 20) = 10;

WeakLP = 10*erf((M(4).Maximum./M(2).Maximum)-1);
WeakLP(M(4).Maximum == 20) = 10;
WeakLP(M(2).Maximum == 20) = 10;

V = [V V2 SyncLP SyncPD PDphase LPphase NeuronMismatch WeakPD WeakLP];

