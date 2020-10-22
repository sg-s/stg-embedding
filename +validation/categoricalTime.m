% validation and type check

function categoricalTime(idx, time)

arguments
	idx (:,1) categorical
	time (:,1) double
end


assert(~any(isundefined(idx)),'Categorical array contains undefined elements. cannot proceed.')
assert(length(time) == length(idx),'Vectors of unequal length')
