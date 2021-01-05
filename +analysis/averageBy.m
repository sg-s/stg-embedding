% average a vector by some group information
% and return the mean and standard deviation of each group

function [M, S] = averageBy(X, Group)

arguments
	X (:,1) double 
	Group (:,1) categorical	
end

unique_groups = unique(Group);
N = length(unique_groups);

M = NaN(N,1);
S = NaN(N,1);

for i = 1:N

	% purge Inf
	this = X(Group == unique_groups(i));
	this(isinf(this)) = [];

	M(i) = nanmean(this);
	S(i) = nanstd(this);
end


