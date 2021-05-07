% reads out manual labels of states 
% from previous annotations from the cache

function [idx, raw_data_hashes] = getLabelsFromCache(alldata)

arguments
	alldata (1,1) embedding.DataStore
end

DataSize = length(alldata.mask);
raw_spike_data = [alldata.LP, alldata.PD];
midx = embedding.makeCategoricalArray(DataSize);
load('../annotations/labels.cache','H','idx','-mat')
[idx, raw_data_hashes] = embedding.readAnnotations(idx,H,raw_spike_data,midx);
idx = removecats(idx);