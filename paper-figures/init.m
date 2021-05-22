% init script
% This script reads in all data and makes it usable
% and is meant to be run before you make any figure
% It should be smart enough to only recompute things 
% as needed

% get the data and filter

if ~exist('alldata','var')
	disp('Reading in all data...')
	[data, datahashes] = sourcedata.getAllData();


	hash = hashlib.md5hash([datahashes{:}]);
	filename = fullfile('..','cache','cleandata.mat');

	if filelib.cacheOK(filename,hash)
		disp('Loading from cache...')
		load(filename,'alldata');
	else
		data = filter(data,sourcedata.DataFilter.AllUsable);
		alldata = data.combine();
		alldata = correctTimeOffsets(alldata);
		save(filename,'alldata','hash','-nocompression');
	end
end


% get the labels and hashes
if ~exist('hashes','var') || any(isundefined(alldata.idx))
	[alldata.idx, hashes.alldata] = alldata.getLabelsFromCache;

end



% get the embedding 
if ~exist('R','var')
	VectorizedData = alldata.spikes2percentiles;

	R = embedding.tsne_data(alldata, PD_LP, LP_PD, VectorizedData);
end


if ~exist('basedata','var')
	disp('Filtering data for baseline and other conditions...')
	basedata = filter(alldata,sourcedata.DataFilter.Baseline);
	decdata = filter(alldata,sourcedata.DataFilter.Decentralized);
	moddata = filter(alldata,sourcedata.DataFilter.Neuromodulator);

	[basedata.idx, hashes.basedata] = basedata.getLabelsFromCache;
	[decdata.idx, hashes.decdata] = decdata.getLabelsFromCache;
	[moddata.idx, hashes.moddata] = moddata.getLabelsFromCache;

end



if ~exist('allmetrics','var')
	disp('Computing metrics for all data...')
	allmetrics = alldata.ISI2BurstMetrics;
	allmetrics = structlib.scalarify(allmetrics);


end



if ~exist('basemetrics','var')
	disp('Computing metrics for baseline data...')
	basemetrics = basedata.ISI2BurstMetrics;
	basemetrics = structlib.scalarify(basemetrics);


	% censor metrics in non-regular states
	fn = fieldnames(basemetrics);
	for i = 1:length(fn)
		basemetrics.(fn{i})(basedata.idx ~= 'regular') = NaN;
	end

end



if ~exist('decmetrics','var')
	disp('Computing metrics for decentralized data...')
	decmetrics = decdata.ISI2BurstMetrics;
	decmetrics = structlib.scalarify(decmetrics);


	% censor metrics in non-regular states
	fn = fieldnames(decmetrics);
	for i = 1:length(fn)
		decmetrics.(fn{i})(decdata.idx ~= 'regular') = NaN;
	end

end



clearvars -except alldata decdata basedata moddata decmetrics basemetrics allmetrics R PD_LP LP_PD hashes VectorizedData


