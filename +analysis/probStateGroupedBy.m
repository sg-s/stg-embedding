% computes the probability of state in groups grouped by something

function [means, group_idx] = probStateGroupedBy(alldata, state, GroupBy)



groupNames = unique(vertcat(alldata.(GroupBy)));

group_idx = [];
means = [];

for i = 1:length(groupNames)

	idx = alldata.idx(alldata.(GroupBy) == groupNames(i));
	exp_id = alldata.experiment_idx(alldata.(GroupBy) == groupNames(i));

	all_exp_id = unique(exp_id);

	if length(all_exp_id) <= 3
		continue
	end

	probability = zeros(length(all_exp_id),1);
	for j = 1:length(all_exp_id)
		probability(j) = mean(idx(exp_id==all_exp_id(j)) == state);
	end

	group_idx = [repmat(groupNames(i),length(probability),1); group_idx];
	means = [probability; means];



end
