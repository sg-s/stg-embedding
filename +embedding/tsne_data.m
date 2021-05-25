% embedding using t-SNE


function R = tsne_data(alldata, PD_LP, LP_PD,VectorizedData, perplexity, R0)

arguments
	alldata (1,1) embedding.DataStore 
	PD_LP
	LP_PD 
	VectorizedData double
	perplexity (1,1) double = 100
	R0 double = NaN
end

opts = struct;
opts.perplexity = perplexity;
opts.late_exag_coeff = 2.5;
opts.start_late_exag_iter = 800;
opts.R0 = R0;

% cache 
hash = hashlib.md5hash([hashlib.md5hash(VectorizedData) structlib.md5hash(opts)]);

cache_loc = (fullfile('../cache',[hash '.mat']));
if exist(cache_loc,'file') == 2
	load(cache_loc,'R')
	return
end


% compute 2nd order ISIs
PD_PD2 = embedding.NthOrderISIs(alldata.PD);
LP_LP2 = embedding.NthOrderISIs(alldata.LP);



% measure 2nd order ISI ratios
% need to do this before we pad ISIs to account for truncated
% segments 
PD_ratios = (max(PD_PD2,[],2)./max(alldata.PD_PD,[],2));
LP_ratios = (max(LP_LP2,[],2)./max(alldata.LP_LP,[],2));

if all(isnan(R0))
	R0 = ([min([PD_LP LP_PD],[],2) max([LP_ratios PD_ratios],[],2)]);
	R0(isnan(R0)) = 0;
	R0 = normalize(R0);
end

opts.initialization = R0;

R = fast_tsne(VectorizedData,opts);

% save to cache
save(cache_loc,'R')