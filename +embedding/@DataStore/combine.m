function DS = combine(data)
% combines a vector of DataStore objects into a single scalar object by concatenating all properties 
DS = embedding.DataStore;
props = properties(DS);
for i = 1:length(props)
	if isscalar(DS.(props{i}))
		DS.(props{i}) = vertcat(data.(props{i}));
	else
		DS.(props{i}) = horzcat(data.(props{i}));
	end
end
