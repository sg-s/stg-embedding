% init script


% get the data and filter
if ~exist('alldata','var')
	disp('Reading in all data...')
	data = sourcedata.getAllData();
	alldata = filter(data,sourcedata.DataFilter.AllUsable);
	alldata = alldata.combine();

	alldata = correctTimeOffsets(alldata);
end


% get the labels and hashes
if ~exist('hashes','var') | any(isundefined(alldata.idx))
	[alldata.idx, hashes.alldata] = alldata.getLabelsFromCache;

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






% get the embedding for the basedata
if ~exist('R','var')
	VectorizedData = alldata.spikes2percentiles;

	R = embedding.tsne_data(alldata, PD_LP, LP_PD, VectorizedData);

	% u = umap;
	% u.n_neighbors = 50;          % 50
	% u.negative_sample_rate = 20;  % 20
	% R = u.fit(VectorizedData);
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


	% censor metrics in non-normal states
	fn = fieldnames(basemetrics);
	for i = 1:length(fn)
		basemetrics.(fn{i})(basedata.idx ~= 'normal') = NaN;
	end

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



clearvars -except alldata decdata basedata moddata decmetrics basemetrics allmetrics R PD_LP LP_PD hashes VectorizedData


