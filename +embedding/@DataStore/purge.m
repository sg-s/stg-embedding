
function data = purge(data,rm_this)

arguments
	data (1,1) embedding.DataStore
	rm_this (:,1) logical 
end

assert(length(rm_this) == length(data.mask),'Expected rm_this to be a vector the same length as data.mask')

data = data.slice(~rm_this);