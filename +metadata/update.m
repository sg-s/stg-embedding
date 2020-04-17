% helper function that is used to update the metadata 
% in the combined data structure

function data = update(data, idx, time, start_time, filename, fieldname, value)


ok = logical(0*data(idx).mask);
for j = 1:length(data(idx).filename)
	if isempty(strfind(char(data(idx).filename(j)),filename))
		continue
	end
	if start_time > time(j)
		continue
	end
	ok(j) = true;
end

start_idx = find(ok,1,'first');


assert(~isempty(start_idx),'Could not determine start_loc location')

data(idx).(fieldname)(start_idx:end) = value;
