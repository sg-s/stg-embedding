% finds nominal burst starts in A (spiketimes from neuron A)
% using information about B (spiketimes from neuron B)
% This works when both neurons are bursting anti-phase,
% and degrades gracefully if this assumption isn't met

function [A_starts, A_stops, A_starts_strict, A_stops_strict] = findNominalBurstStartsStops(A,B)


% compute A burst starts
A_starts = false(length(A),1);
A_stops = false(length(A),1);
A_starts_strict = false(length(A),1);
A_stops_strict = false(length(A),1);

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
		A_starts(j) = true;


		if next_A_spike < next_B_spike
			A_starts_strict(j) = true;
		end

	end

	if next_A_spike > next_B_spike
		A_stops(j) = true;

		if last_A_spike > last_B_spike
			A_stops_strict(j) = true;
		end

	end



	
end

% the NaN padding is to ensure that these arrays are never empty
A_starts = [A(A_starts) NaN NaN NaN];
A_stops = [A(A_stops) NaN NaN NaN];
A_starts_strict = [A(A_starts_strict) NaN NaN NaN];
A_stops_strict = [A(A_stops_strict) NaN NaN NaN];

A_burst_period = nanmax(diff(A_starts));
A_burst_period_strict = nanmax(diff(A_starts_strict));


% make sure bursting doesn't start too late or stop too early
if A_starts(1) > A_burst_period
	A_starts = [0 A_starts];
end


if 20-nanmax(A_starts) > A_burst_period
	A_starts(end) = 20;
	A_starts = sort(A_starts);
end

% make sure bursting doesn't start too late or stop too early
if A_starts_strict(1) > A_burst_period_strict
	A_starts_strict = [0 A_starts_strict];
end


if 20-nanmax(A_starts_strict) > A_burst_period_strict
	A_starts_strict(end) = 20;
	A_starts_strict = sort(A_starts_strict);
end