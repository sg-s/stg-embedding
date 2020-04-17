% combines a vector of structs into a single data structure

function [alldata, data] = combine(data)



% combine all data
for i = 1:length(data)
	data(i).PD = data(i).PD';
	data(i).LP = data(i).LP';
	data(i).PD_PD = data(i).PD_PD';
	data(i).PD_LP = data(i).PD_LP';
	data(i).LP_LP = data(i).LP_LP';
	data(i).LP_PD = data(i).LP_PD';
	data(i).time_offset = data(i).time_offset';
end

fn = fieldnames(data);
	for i = 1:length(fn)
	alldata.(fn{i}) = vertcat(data.(fn{i}));
end

% purge masked data
rm_this = ~alldata.mask;
for i = 1:length(fn)
	alldata.(fn{i}) = alldata.(fn{i})(~rm_this,:);
end