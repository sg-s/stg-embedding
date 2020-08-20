% init script


% get the data and filter
if ~exist('alldata','var')
	disp('Reading in all data...')
	data = sourcedata.getAllData();
	alldata = filter(data,sourcedata.DataFilter.AllUsable);
	alldata = alldata.combine();
end


if ~exist('basedata','var')
	disp('Filtering data for baseline and other conditions...')
	basedata = filter(alldata,sourcedata.DataFilter.Baseline);
	decdata = filter(alldata,sourcedata.DataFilter.Decentralized);
end


% get the labels and hashes
if ~exist('hashes','var') | any(isundefined(alldata.idx))
	[alldata.idx, hashes.alldata] = alldata.getLabelsFromCache;
	[basedata.idx, hashes.basedata] = basedata.getLabelsFromCache;
	[decdata.idx, hashes.decdata] = decdata.getLabelsFromCache;
end

assert(~any(isundefined(alldata.idx)),'Some data is unlabeled')

% get the embedding
if ~exist('R','var')
	[p,NormalizedMetrics, VectorizedData] = alldata.vectorizeSpikes2;
	u = umap('min_dist',.75, 'metric','euclidean','n_neighbors',75,'negative_sample_rate',25);
	u.labels = alldata.idx;
	R = u.fit(VectorizedData);
end



if ~exist('decmetrics','var')
	disp('Computing metrics for decentralized data...')
	decmetrics = decdata.ISI2BurstMetrics;
	decmetrics = structlib.scalarify(decmetrics);


	% censor metrics in non-normal states
	fn = fieldnames(decmetrics);
	for i = 1:length(fn)
		decmetrics.(fn{i})(decdata.idx ~= 'normal') = NaN;
	end

end



if ~exist('basemetrics','var')
	disp('Computing metrics for baseline data...')
	basemetrics = basedata.ISI2BurstMetrics;
	basemetrics = structlib.scalarify(basemetrics);


	% censor metrics in non-normal states
	fn = fieldnames(basemetrics);
	for i = 1:length(fn)
		basemetrics.(fn{i})(basedata.idx ~= 'normal') = NaN;
	end

end



clearvars -except alldata data R metrics basedata decdata hashes decmetrics basemetrics