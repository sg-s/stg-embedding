% computes a new vector, called time_since_decentralization
% which is as long as data.mask
% which contains a useful time axis
% this time vector is 0 at the time of decentralization,
% and is defined for all contiguous blocks before and after that 0
% at all other times, it will be either -Inf or +Inf based on 
% whether it is after or before decentralization 

function time_since_decentralization = timeSinceDecentralization(data)

arguments
	data (1,1) embedding.DataStore
end


time_since_decentralization = NaN(length(data.mask),1);
all_preps = unique(data.experiment_idx);
for i = 1:length(all_preps)
	use_this = data.experiment_idx == all_preps(i);

	if ~any(use_this)
		continue
	end

	idx = data.idx(use_this);
	time = data.time_offset(use_this);
	decentralized = data.decentralized(use_this);
	

	breaks = (find(diff(time)<0));
	d = find(decentralized,1,'first');

	if isempty(d)
		time_since_decentralization(use_this) = -Inf;
		continue
	end


	first_usable = max(breaks(breaks<d));
	last_usable = min(breaks(breaks>d));

	time(1:first_usable) = -Inf;
	time(last_usable+1:end) = Inf;

	time = time - time(find(decentralized,1,'first'));

	% sanity checks
	try
		assert(length(unique(time(~isinf(time)))) == length(time(~isinf(time))),'Lengths not equal. FATAL')

		time_since_decentralization(use_this) = time;
	catch
		
	end

	

end
