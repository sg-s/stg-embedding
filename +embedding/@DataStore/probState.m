% computes the probability of all states in the data
% on a per-prep basis

function P  = probState(data, OnlyWhen)

arguments

	data(1,1) embedding.DataStore
	OnlyWhen (:,1) logical 
	
end


if nargin == 1
	OnlyWhen = true(length(data.mask),1);
end



assert(length(OnlyWhen) == length(data.mask),'OnlyWhen has an incongruent length')
assert(~any(isundefined(data.idx)),'States not defined!')

all_states = categories(data.idx);


all_preps = unique(data.experiment_idx);

cats = categories(data.idx);
P = zeros(length(all_preps),length(cats));

for i = 1:length(all_preps)
	idx = data.idx(data.experiment_idx == all_preps(i) & OnlyWhen);
	P(i,:) = histcounts(idx,'Normalization','probability');

end


