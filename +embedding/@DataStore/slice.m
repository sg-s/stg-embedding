% slice into a DataStore using some logical operation
% this is the sort of opposite of purge()

function data = slice(data, keep_this)

arguments
	data (1,1) embedding.DataStore
	keep_this (:,1) logical 
end


assert(length(keep_this) == length(data.mask),'keep_this must match the length of vectors in the dataStore')


props = properties(data);

DS = struct(data);



for i = 1:length(props)
	DS.(props{i}) = data.(props{i})(keep_this,:);
end
% 3 seconds

data = embedding.DataStore(DS,true);

