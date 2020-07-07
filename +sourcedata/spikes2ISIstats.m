% converts ISIs to summary statistics in a semi-designed way
% mean to replace spiketimes2percentiles
% 
function [V,M] = spikes2ISIstats(data)

DataSize = length(data.mask);


% construct the 2nd order ISIs
neurons = {'PD','LP'};
for i = 1:length(neurons)


	data.([neurons{i} '_' neurons{i} '2']) = NaN(DataSize,1e3);

	for j = 1:DataSize
		spikes = data.(neurons{i})(j,:);

		% check if there is a large empty section
		maxisi = max(diff(spikes));
		if (20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes)))) > maxisi
			spikes(find(isnan(spikes),1,'first')) = max(spikes)+(20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes))));
		end


		spikes2 = circshift(spikes,2);

		isis = spikes-spikes2;
		isis(isis<0.001) = NaN;

		data.([neurons{i} '_' neurons{i} '2'])(j,:) = isis;

		
	end
end


fn = {'PD_PD','LP_LP','PD_LP','LP_PD','PD_PD2','LP_LP2'};

M = struct;


for i = 1:length(fn)

	disp(fn{i})

	X = data.(fn{i});


	M(i).Minimum = nanmin(X,[],2);
	M(i).Maximum = nanmax(X,[],2);
	M(i).Median = nanmedian(X,2);

	M(i).DominantPeriod = NaN*M(i).Maximum;
	M(i).Irregularity = NaN*M(i).Maximum;
	
	if i < 3 | i > 4

		% compute dominant period from ISIs
		M(i).DominantPeriod = sourcedata.ISI2DominantPeriod(X);

		% capture irregularity 
		% very negative values here indicate irregularity 
		M(i).Irregularity = M(i).DominantPeriod - M(i).Maximum;
		M(i).Irregularity(isnan(M(i).Irregularity)) = -10;

		% exxagerate the irregulairty around 0
		temp = erf(M(i).Irregularity*10);
		M(i).Irregularity = temp + M(i).Irregularity;
		clearvars temp
		
	end


	% capture "burstiness"
	M(i).MaxMin = M(i).Maximum - M(i).Minimum;
	M(i).MaxMedian = M(i).Maximum - M(i).Median;


	% capture burst regularity
	% Max2 = NaN(DataSize,1);
	% Max3 = NaN(DataSize,1);
	% Max4 = NaN(DataSize,1);
	% Max5 = NaN(DataSize,1);

	% parfor j = 1:DataSize
	% 	Y = sort(X(j,:),'descend');
	% 	Y(isnan(Y)) = [];

	% 	switch length(Y)
	% 	case 0
	% 		continue
	% 	case 1
	% 		continue
	% 	case 2
	% 		Max2(j) = Y(1) - Y(2);
	% 	case 3 
	% 		Max2(j) = Y(1) - Y(2);
	% 		Max3(j) = Y(1) - Y(3);
	% 	case 4
	% 		Max2(j) = Y(1) - Y(2);
	% 		Max3(j) = Y(1) - Y(3);
	% 		Max4(j) = Y(1) - Y(4);
	% 	otherwise
	% 		Max2(j) = Y(1) - Y(2);
	% 		Max3(j) = Y(1) - Y(3);
	% 		Max4(j) = Y(1) - Y(4);
	% 		Max5(j) = Y(1) - Y(5);
	% 	end
	% end

	% M(i).Max2 = Max2;
	% M(i).Max3 = Max3;
	% M(i).Max4 = Max4;
	% M(i).Max5 = Max5;

end

V = struct2array(M);
V(isnan(V)) = -1;


% delete columns with zero information
% because some columns are not defined, and are just dummy data
V(:,std(V)==0) = [];

% also add something that scales with the inverse firing rate (so in units of time)
V2 = [20./sum(~isnan(data.PD),2) 20./sum(~isnan(data.LP),2)];
V2(isinf(V2)) = -1;
V2(isnan(V2)) = -1;



% also measure the maximum time without a spike
% PD = data.PD;
% LP = data.LP;
% for i = 1:size(PD,1)
% 	PD(i,:) = PD(i,:) - min(PD(i,:));
% 	LP(i,:) = LP(i,:) - min(LP(i,:));
% end
% MaxNoPD = 20 - max(PD,[],2); MaxNoPD(isnan(MaxNoPD)) = 20;
% MaxNoLP = 20 - max(LP,[],2); MaxNoLP(isnan(MaxNoLP)) = 20;

V = [V V2];


% normalize the different columns to correct for scale differnces in dimensions
for i = 1:length(M)
	M = mean(V(V(:,i) > 0,i));
	S = std(V(V(:,i) > 0,i));

	V(:,i) = V(:,i) - M;
	V(:,i) = V(:,i)/S;
end
