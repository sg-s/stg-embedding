% init script


% get the data and filter
if ~exist('data','var')
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

% compute metrics

if ~exist('metrics','var')
	metrics = alldata.ISI2BurstMetrics;
	metrics = structlib.scalarify(metrics);
end


clearvars -except alldata data R metrics basedata decdata hashes