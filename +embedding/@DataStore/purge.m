
function data = purge(data,rm_this)

arguments
	data (1,1) embedding.DataStore
	rm_this (:,1) logical 
end

assert(isscalar(data),'Expected data to be scalar')
assert(length(rm_this) == length(data.mask),'Expected rm_this to be a vector the same length as data.mask')
assert(islogical(rm_this),'Expected rm_this to be logical')
rm_this = rm_this(:);
assert(length(data.mask) == length(rm_this),'Expected rm_this to be the same length as data.mask')

props = properties(data);


for i = 1:length(props)
	data.(props{i})(rm_this,:) = [];
end

