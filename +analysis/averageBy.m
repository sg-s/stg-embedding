function M = averageBy(X,Group)

unique_groups = unique(Group);
N = length(unique_groups);

M = NaN(N,1);

for i = 1:N

	M(i) = nanmean(X(Group == unique_groups(i)));

end