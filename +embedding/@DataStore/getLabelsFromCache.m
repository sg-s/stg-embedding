% reads out manual labels of states 
% from previous annotations from the cache

function idx = getLabelsFromCache(alldata)

assert(length(alldata) == 1,'Expected a scalar DataStore')

DataSize = length(alldata.mask);
raw_spike_data = [alldata.LP, alldata.PD];
midx = embedding.makeCategoricalArray(DataSize);
load('../annotations/labels.cache','H','idx','-mat')
idx = embedding.readAnnotations(idx,H,raw_spike_data,midx);