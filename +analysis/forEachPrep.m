% perform some operation for each prep 
% in the datastore

function Y = forEachPrep(data, func)


arguments
	data (1,1) embedding.DataStore
	func

end

unique_preps = unique(data.experiment_idx);

Y = zeros(length(data.mask),1);

for i = 1:length(unique_preps)

	prep = data.slice(data.experiment_idx == unique_preps(i));

	Y(data.experiment_idx==unique_preps(i)) = func(prep);

end