% builds a matrix of prep by time
% for something
% it creates a matrix of size length(unique_preps) x time_vec
% where time_vec is expected to be some nice time like vector
%
function X = prepTimeMatrix(preps, time, Thing, time_vec)

assert(iscategorical(preps),'Expected preps to be a categorical array')
assert(isvector(preps),'Expected preps to be a vector')
assert(length(time)==length(preps),'Expected preps and time to be of the same size')
assert(length(Thing)==length(time),'Expected preps and Thing to be of the same size')


all_preps = unique(preps);
X = repmat(feval(class(Thing),NaN),length(all_preps),length(time_vec));



for i = 1:length(all_preps)
	use_this = preps == all_preps(i);
	this_thing = Thing(use_this);
	this_time = time(use_this);

	for j = 1:length(time_vec)
		insert_this = this_thing(this_time == time_vec(j));
		if isempty(insert_this)
			continue
		end
		X(i,j) = insert_this;

	end


end