% a method of embedding.DataStore 
% that splits data by experiment
% and returns a vector of DataStore object

function preps = split(data)

assert(length(data)==1,'Expected a scalar datastore')


all_exps = unique(data.experiment_idx);

for i = length(all_exps):-1:1
	preps(i) = data.slice(data.experiment_idx==all_exps(i));
end