% this method converts ISIs into binarized histograms

function [p, VectorizedData] = binarizedHistograms(alldata, varargin)


N = length(alldata.mask);

options.MaxISI = 3;
options.MinISI = 1e-2;
options.NBins = 10;


% get options from dependencies 
options = corelib.parseNameValueArguments(options,varargin{:});


% pull out spike info and ISIs into a structure
data.PD = alldata.PD;
data.LP = alldata.LP;
data.PD_PD = alldata.PD_PD;
data.LP_LP = alldata.LP_LP;
data.PD_LP = alldata.PD_LP;
data.LP_PD = alldata.LP_PD;

% clean up spikes -- remove first spike time from each set
offset = (nanmin([data.PD data.LP],[],2));
for i = 1:N
	if ~isnan(offset(i))
		data.PD(i,:) = data.PD(i,:) - offset(i);
		data.LP(i,:) = data.LP(i,:) - offset(i);
	end
end


% account for gaps in 1st order ISIs
last_PD = nanmax(data.PD,[],2);
last_LP = nanmax(data.LP,[],2);
max_PD = nanmax(data.PD_PD,[],2);
max_LP = nanmax(data.LP_LP,[],2);

for i = 1:N
	if (20-last_PD(i)) > max_PD(i)
		data.PD_PD(i,find(isnan(data.PD_PD(i,:)),1,'first')) = 20 - last_PD(i);
	end
	if (20-last_LP(i)) > max_LP(i)
		data.LP_LP(i,find(isnan(data.LP_LP(i,:)),1,'first')) = 20 - last_LP(i);
	end
end


% construct the 2nd order ISIs
neurons = {'PD','LP'};
for i = 1:length(neurons)

	data.([neurons{i} '_' neurons{i} '2']) = NaN(N,1e3);

	for j = 1:N
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






MaxISI = log10(options.MaxISI);
MinISI = log10(options.MinISI);


BinEdges = [0 logspace(MinISI,MaxISI,options.NBins-1) 20];
DelayBinEdges = [0 logspace(MinISI,0,options.NBins-1) 20];

for i = N:-1:1

	LP_LP(i,:) = histcounts(data.LP_LP(i,:),'BinEdges',BinEdges);
	PD_PD(i,:) = histcounts(data.PD_PD(i,:),'BinEdges',BinEdges);

	LP_LP2(i,:) = histcounts(data.LP_LP2(i,:),'BinEdges',BinEdges);
	PD_PD2(i,:) = histcounts(data.PD_PD2(i,:),'BinEdges',BinEdges);

	LP_PD(i,:) = histcounts(data.LP_PD(i,:),'BinEdges',DelayBinEdges);
	PD_LP(i,:) = histcounts(data.PD_LP(i,:),'BinEdges',DelayBinEdges);
end


p.LP_LP = LP_LP;
p.PD_PD = PD_PD;
p.PD_LP = PD_LP;
p.LP_PD = LP_PD;
p.LP_LP2 = LP_LP2;
p.PD_PD2 = PD_PD2;

% binarize
% LP_LP(LP_LP>0)=1;
% PD_PD(PD_PD>0)=1;
% PD_LP(PD_LP>0)=1;
% LP_PD(LP_PD>0)=1;
% LP_LP2(LP_LP2>0)=1;
% PD_PD2(PD_PD2>0)=1;

% cumsum
LP_LP = cumsum(LP_LP,2);
PD_PD = cumsum(PD_PD,2);
PD_LP = cumsum(PD_LP,2);
LP_PD = cumsum(LP_PD,2);
LP_LP2 = cumsum(LP_LP2,2);
PD_PD2 = cumsum(PD_PD2,2);

for i = 1:N
	LP_LP(i,:) = LP_LP(i,:)/LP_LP(i,end);
	PD_PD(i,:) = PD_PD(i,:)/PD_PD(i,end);
	PD_LP(i,:) = PD_LP(i,:)/PD_LP(i,end);
	LP_PD(i,:) = LP_PD(i,:)/LP_PD(i,end);
	LP_LP2(i,:) = LP_LP2(i,:)/LP_LP2(i,end);
	PD_PD2(i,:) = PD_PD2(i,:)/PD_PD2(i,end);
end

VectorizedData = [PD_PD LP_LP LP_PD PD_LP PD_PD2 LP_LP2];

VectorizedData(isnan(VectorizedData)) = 0;
VectorizedData(isinf(VectorizedData)) = 0;
