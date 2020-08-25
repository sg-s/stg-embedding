% computes the probability of one state in groups grouped by something
% computed on a prep-by-prep basis
% you cannot use 'experiment_idx' as the grouping variable


function [means, group_idx] = probStateGroupedBy(alldata, state, GroupBy)

arguments
	alldata (1,1) embedding.DataStore
	state char
	GroupBy char 

end

assert(length(alldata)==1,'Expected a scalar DataStore')
assert(~any(isundefined(alldata.idx)),'States are undefined')

assert(~strcmp(GroupBy,'experiment_idx'),'You cannot use experiment_idx to group by')
assert(isprop(alldata,GroupBy),'GroupBy should be a DataStore property')


groupNames = unique(vertcat(alldata.(GroupBy)));

if iscategorical(groupNames)
	groupNames(isundefined(groupNames)) = [];
end

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
