% delete part of a dataset
function data = purge(data, idx)

assert(length(data)==1,'Can only work with scalar data')

fn = fieldnames(data);

for i = 1:length(fn)


	if isvector(data.(fn{i}))
		data.(fn{i})(idx) = [];
	else
		data.(fn{i})(:,idx) = [];
	end
end