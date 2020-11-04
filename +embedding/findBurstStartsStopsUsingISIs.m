% this function attempts to find burst starts and stops
% from raw spiketimes 
% the way it works is that the smallest IBI can be determined by
% looking at the biggest jump in sorted ISIs. 
% this gracefully degrades for non-bursting spike trains

function [A_starts, A_stops] = findBurstStartsStopsUsingISIs(A)

isis = diff(A);
sorted_isis = sort(isis);
[~,idx] = max(diff(sort(sorted_isis)));

min_ibi = sorted_isis(idx+1);

burst_stops_idx = find(isis>=min_ibi);
A_stops = A(burst_stops_idx);
A_starts = A(burst_stops_idx+1);

A_starts = [A_starts NaN NaN NaN];
A_stops = [A_stops NaN NaN NaN];




