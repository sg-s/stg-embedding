function [dwell_times, times_bw_transitions] = dwellTimes(idx, time, shuffle)

if nargin == 2
	shuffle = false;
end

assert(isvector(idx),'Expected idx to be a vector')
assert(isvector(time),'Expected time to be a vector')
assert(iscategorical(idx),'Expected idx to be categorical')
assert(length(idx) == length(time),'Expected idx and time to be of equal length')

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


if shuffle
	return
end

% % now shuffle the states and compute dwell times
% N = 100;
% shuffled_dwell_times = NaN(length(cats),N);
% parfor i = 1:N
% 	these_dwell_times = analysis.dwellTimes(idx,time,true);
% 	shuffled_dwell_times(:,i) = nanmean(these_dwell_times');
% end

