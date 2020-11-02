% computes dwell times for each category 
% of dynamics 

function [dwell_times, times_bw_transitions] = dwellTimes(idx, time, shuffle)


arguments
	idx (:,1) categorical
	time (:,1) double
	shuffle (1,1) logical = false
	
end


validation.categoricalTime(idx,time);


cats = categories(idx);

if shuffle
	idx = veclib.shuffle(idx);
end

% find the break points
breakpts = [0; find((diff(time)) ~= 20)];

dwell_times = NaN(length(cats),length(breakpts)-1);
times_bw_transitions = [];

for i = 1:length(breakpts)-1

	this_idx = idx(breakpts(i)+1:breakpts(i+1));

	dwell_times(:,i) = analysis.dwellTimesInSegment(this_idx);

	times_bw_transitions = [times_bw_transitions; diff(find(~(this_idx == circshift(this_idx,1))))];


end

