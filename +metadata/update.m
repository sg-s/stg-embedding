% helper function that is used to update the metadata 
% in the combined data structure

function data = update(data, time, start_time, filename, fieldname, value)


arguments
	data (1,1) struct
	time (:,1) double
	start_time
	filename char 
	fieldname char 
	value (1,1)
end


ok = logical(0*data.mask);
for j = 1:length(data.filename)
	if isempty(strfind(char(data.filename(j)),filename))
		continue
	end
	if start_time < time(j)
		continue
	end
	ok(j) = true;
end

start_idx = find(ok,1,'last');


assert(~isempty(start_idx),'Could not determine start_loc location')

data.(fieldname)(start_idx:end) = value;

