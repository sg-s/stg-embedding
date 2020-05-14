% validation and type check

function categoricalTime(idx, time)

assert(iscategorical(idx),'Argument must be a categorical array')
assert(isvector(idx),'Argument must be a vector')
assert(isvector(time),'time should be a vector ')
idx = idx(:);
assert(~any(isundefined(idx)),'Categorical array contains undefined elements. cannot proceed.')
assert(length(time) == length(idx),'Vectors of unequal length')
