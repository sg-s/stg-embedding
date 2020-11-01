% the time_offset in the DataStore
% resets to 0 every time a file switches
% this is overly strict, and a little bit wrong
% Instead, the best thing to do is to look at the filenames
% and if the filenames have consecutive file identifiers,
% then we should continue the time_offset
%
% assumptions: chunkSize is 20 s

function data = correctTimeOffsets(data)

arguments
	data (1,1) embedding.DataStore
end


all_preps = unique(data.experiment_idx);

for i = 1:length(all_preps)
	prep = data.slice(data.experiment_idx == all_preps(i));

	time_zeros = find(prep.time_offset == 0);

	if length(time_zeros) < 2
		continue
	end


	for j = 2:length(time_zeros)

		this_file_idx = strsplit(char(prep.filename(time_zeros(j))),'_');
		this_file_idx = str2double(this_file_idx{end});

		prev_file_idx = strsplit(char(prep.filename(time_zeros(j)-1)),'_');
		prev_file_idx = str2double(prev_file_idx{end});



		if prev_file_idx + 1 == this_file_idx
			% can be treated as a continuation 
			this = prep.filename == prep.filename(time_zeros(j));
			prep.time_offset(this) = prep.time_offset(this) + prep.time_offset(time_zeros(j)-1) + 20;
		end
	end

	data.time_offset(data.experiment_idx == all_preps(i)) = prep.time_offset;

end