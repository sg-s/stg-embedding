% computes the time it takes for each point to change its state
% when not defined, is given an Inf value

function dwell_time = timeToStateChange(idx, time)

arguments
	idx (:,1) categorical
	time (:,1) double
end

validation.categoricalTime(idx,time);

dwell_time = time;
dwell_time(:) = NaN;


for i = 1:length(time)-1

	z = i + find(time(i+1:end)==0,1,'first');

	next_switch = find(idx(i:z-1) ~= idx(i),1,'first');

	if isempty(next_switch)
		continue
	end

	dwell_time(i) = next_switch;

end

dwell_time = dwell_time*20;

