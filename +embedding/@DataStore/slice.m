% slice into a DataStore using some logical operation
% this is the sort of opposite of purge()

function data = slice(data, keep_this)

arguments
	data (1,1) embedding.DataStore
	keep_this (:,1) logical 
end

props = properties(data);
for i = 1:length(props)
	data.(props{i}) = data.(props{i})(keep_this,:);
end

