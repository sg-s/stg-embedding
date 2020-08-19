% computes a new vector, called time_since_decentralization
% which is as long as data.mask
% which contains a useful time axis

function time_since_decentralization = timeSinceDecentralization(decdata)

assert(isa(decdata,'embedding.DataStore'),'Expected a embedding.DataStore')
assert(length(decdata)==1,'Expected a scalar DataStore')

time_since_decentralization = NaN(length(decdata.mask),1);
all_preps = unique(decdata.experiment_idx);
for i = 1:length(all_preps)
	use_this = decdata.experiment_idx == all_preps(i);
	idx = decdata.idx(use_this);
	time = decdata.time_offset(use_this);
	decentralized = decdata.decentralized(use_this);
	

	breaks = (find(diff(time)<0));
	d = find(decentralized,1,'first');

	first_usable = max(breaks(breaks<d));
	last_usable = min(breaks(breaks>d));

	time(1:first_usable) = NaN;
	time(last_usable+1:end) = NaN;

	time_since_decentralization(use_this) = time - time(find(decentralized,1,'first'));

end
