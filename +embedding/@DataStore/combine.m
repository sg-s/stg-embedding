function DS = combine(data)
% combines a vector of DataStore objects into a single scalar object by concatenating all properties 
DS = embedding.DataStore;
props = properties(DS);
for i = 1:length(props)
	DS.(props{i}) = vertcat(data.(props{i}));
end
