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





% A_burst_period = nanmax(diff(A_starts));


% % make sure bursting doesn't start too late or stop too early
% if A_starts(1) > A_burst_period

% 	if A(1) > A_burst_period
% 		% add first spike
% 		A_starts = [A(1) A_starts];
% 	end

% 	if A_starts(1) > A_burst_period
% 		A_starts = [0 A_starts];
% 	end

% end


% if 20-nanmax(A_starts) > A_burst_period
% 	A_starts(end) = 20;
% 	A_starts = sort(A_starts);
% end


% figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
% neurolib.raster(A,'deltat',1,'center',false)
% plot(A_starts,A_starts*0+.95,'gd')
% plot(A_stops,A_stops*0+.95,'ro')
% error('NO')