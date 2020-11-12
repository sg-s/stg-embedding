% converts a DataStore into a structure

function S = struct(self)

assert(length(self)==1,'Only works for scalar DataStores')

S = struct;
props = properties(self);

for i = 1:length(props)
	S.(props{i}) = self.(props{i});
end