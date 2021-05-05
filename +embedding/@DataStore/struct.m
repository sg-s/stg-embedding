% converts a DataStore into a structure
% the reason this exists, and we use it, instead
% of the built-in struct function is so that
% we can easily suppress the annoying warning MATLAB
% generates when calling struct(object)

function S = struct(self)

assert(length(self)==1,'Only works for scalar DataStores')

S = struct;
props = properties(self);

for i = 1:length(props)
	S.(props{i}) = self.(props{i});
end