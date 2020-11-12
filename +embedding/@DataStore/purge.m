
function data = purge(data,rm_this)

arguments
	data (1,1) embedding.DataStore
	rm_this (:,1) logical 
end

assert(length(rm_this) == length(data.mask),'Expected rm_this to be a vector the same length as data.mask')

props = properties(data);

data = data.struct();

for i = 1:length(props)
	data.(props{i})(rm_this,:) = [];
end

data = embedding.DataStore(data);