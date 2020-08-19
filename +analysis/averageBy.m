% average a vector by some group information

function [M, S] = averageBy(X,Group)

unique_groups = unique(Group);
N = length(unique_groups);

M = NaN(N,1);
S = NaN(N,1);

for i = 1:N

	M(i) = nanmean(X(Group == unique_groups(i)));
	S(i) = nanstd(X(Group == unique_groups(i)));
end