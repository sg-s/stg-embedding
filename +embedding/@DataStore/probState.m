% computes the probability of all states in the data
% on a per-prep basis

function P = probState(data, OnlyWhen)

assert(isscalar(data),'Expected a scalar DataStore')
assert(~any(isundefined(data.idx)),'States not defined!')

all_states = categories(data.idx);


if nargin == 1
	OnlyWhen = true(length(data.mask),1);
end


assert(islogical(OnlyWhen),'Expected OnlyWhen to be a logical vector')
assert(length(OnlyWhen) == length(data.mask),'OnlyWhen has an incongruent length')


all_preps = unique(data.experiment_idx);

cats = categories(data.idx);
P = zeros(length(all_preps),length(cats));

for i = 1:length(all_preps)
	idx = data.idx(data.experiment_idx == all_preps(i));
	P(i,:) = histcounts(idx,'Normalization','probability');

end


