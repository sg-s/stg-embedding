% finds nominal burst starts in A (spiketimes from neuron A)
% using information about B (spiketimes from neuron B)
% This works when both neurons are bursting anti-phase,
% and degrades gracefully if this assumption isn't met

function [A_burst_starts, A_burst_stops] = findNominalBurstStartsStops(A,B)


% compute A burst starts
A_burst_starts = false(length(A),1);
A_burst_stops = false(length(A),1);


for j = 1:999  % we know each data frame has only a 1000 spikes at max
	if isnan(A(j))
		break
	end


	if j == 1
		last_A_spike = -Inf;
	else
		last_A_spike = A(j-1);
	end
	next_A_spike = A(j+1);


	if isnan(next_A_spike)
		next_A_spike = Inf;
	end

	last_B_spike_idx = find(B<A(j),1,'last');


	if isempty(last_B_spike_idx)
		last_B_spike = -Inf;
		next_B_spike = B(find(B>A(j),1,'first'));
	else
		last_B_spike = B(last_B_spike_idx);

		if last_B_spike_idx == 1e3
			next_B_spike = Inf;
		else
			next_B_spike = B(last_B_spike_idx+1);
		end

	end
	
	
	if isempty(next_B_spike)
		next_B_spike = Inf;
	end

	if last_B_spike > last_A_spike
		A_burst_starts(j) = true;
	end

	if next_A_spike > next_B_spike
		A_burst_stops(j) = true;
	end
	
end

% the NaN padding is to ensure that these arrays are never empty
A_burst_starts = [A(A_burst_starts) NaN NaN];
A_burst_stops = [A(A_burst_stops) NaN NaN];


A_burst_period = nanmean(diff(A_burst_starts));

if isnan(A_burst_period)
	return
end

% make sure bursting doesn't start too late or stop too early
if A_burst_starts(1) > A_burst_period*2
	A_burst_starts = [0 A_burst_starts];
end


if 20-A_burst_starts(end-2) > 2*A_burst_period
	A_burst_starts(end-1) = 20;
end