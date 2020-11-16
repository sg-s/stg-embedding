% perform some operation for each prep 
% in the datastore
% returns a vector as long as the data.mask
% YM contains the mean averaged across each prep

function [Y, YM] = forEachPrep(data, func)


arguments
	data (1,1) embedding.DataStore
	func (1,1) function_handle

end

unique_preps = unique(data.experiment_idx);

Y = zeros(length(data.mask),1);
YM = zeros(length(unique_preps),1);

for i = 1:length(unique_preps)

	prep = data.slice(data.experiment_idx == unique_preps(i));

	Y(data.experiment_idx==unique_preps(i)) = func(prep);

	YM(i) = mean(Y(data.experiment_idx==unique_preps(i)));

end