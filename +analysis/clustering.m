% this performs an analysis on clustering
% and returns a probability that the N closest 
% points in each group belong to that
% group. 

function [clustering_prob, rand_prob, N, unique_labels]=clustering(data, R, GroupBy, OnlyWhen)

arguments
	data (1,1) embedding.DataStore
	R (:,2) double 
	GroupBy char =  'experiment_idx'
	OnlyWhen (:,1) logical = true(length(R),1)

end

validation.firstDimensionEqualSize(data.mask,OnlyWhen);
assert(isprop(data,GroupBy))

assert(all(iscategorical(data.(GroupBy))),'Grouping variable should be categorical')


unique_labels = unique(data.(GroupBy));


clustering_prob = zeros(length(unique_labels),1);

N = zeros(length(unique_labels),1);
N_bootstrap = 1;
rand_prob = zeros(length(unique_labels),N_bootstrap);


for i = 1:length(unique_labels)

	corelib.textbar(i,length(unique_labels))

	this = data.(GroupBy) == unique_labels(i) & OnlyWhen;
	N(i) = sum(this);

	clustering_prob(i) = analysis.probabilityNClosestPointInGroup(R,this);


	for j = 1:N_bootstrap

		temp = veclib.shuffle(1:length(R));
		temp = temp(1:sum(this));
		this2 = false(length(R),1);
		this2(temp) = true;

		rand_prob(i,j) = rand_prob(i,j) + analysis.probabilityNClosestPointInGroup(R,this2);

	end
end
