% init script

data = sourcedata.getAllData();
alldata = filter(data,sourcedata.DataFilter.AllUsable);
alldata = alldata.combine();

[alldata.idx, alldata_hashes] = alldata.getLabelsFromCache;

assert(~any(isundefined(alldata.idx)),'Some data is unlabeled')

% get the embedding
[p,NormalizedMetrics, VectorizedData] = alldata.vectorizeSpikes2;

% original
u = umap('min_dist',.75, 'metric','euclidean','n_neighbors',75,'negative_sample_rate',25);
u.labels = alldata.idx;
R = u.fit(VectorizedData);



% compute burst metrics

if ~exist('burst_metrics','var')
	burst_metrics = alldata.ISI2BurstMetrics;
	burst_metrics = structlib.scalarify(burst_metrics);
end



clearvars -except alldata data R burst_metrics basedata alldata_hashes