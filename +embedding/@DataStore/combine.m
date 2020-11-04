% combines a vector of DataStore objects into a single scalar object by concatenating all properties 
% because DataStore objects are immutable, we have to jump
% through some hoops to construct the new combined DataStore

function DS = combine(data)

DS = struct;
props = properties(data);
for i = 1:length(props)
	DS.(props{i}) = vertcat(data.(props{i}));
end

DS = embedding.DataStore(DS);