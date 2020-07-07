% combines a vector of embedding.DataStore into a scalar structure

function [ScalarData, DataStruct] = combine(DSArray)

assert(isa(DSArray,'embedding.DataStore'),'Expected argument to be of type embedding.DataStore')

% first convert into a structure
fn = {};
for i = 1:length(DSArray)
	fn = unique([fn; properties(DSArray(i))]);
end


for i = length(DSArray):-1:1
	for j = 1:length(fn)
		DataStruct(i).(fn{j}) = DSArray(i).(fn{j});
	end
	
end



% rotate arrays
for i = 1:length(DataStruct)
	DataStruct(i).PD = DataStruct(i).PD';
	DataStruct(i).LP = DataStruct(i).LP';
	DataStruct(i).PD_PD = DataStruct(i).PD_PD';
	DataStruct(i).PD_LP = DataStruct(i).PD_LP';
	DataStruct(i).LP_LP = DataStruct(i).LP_LP';
	DataStruct(i).LP_PD = DataStruct(i).LP_PD';
end


for i = 1:length(fn)
	disp(fn{i})
	ScalarData.(fn{i}) = vertcat(DataStruct.(fn{i}));
end

% purge masked data
rm_this = ~ScalarData.mask;
for i = 1:length(fn)
	ScalarData.(fn{i}) = ScalarData.(fn{i})(~rm_this,:);
end