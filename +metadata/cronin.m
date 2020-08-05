function data = cronin(data, metadata_loc)

mods = {'RPCH','proctolin','CCAP'};
p = properties(data(1));
mods = setdiff(mods,p);
for i = 1:length(mods)
	addprop(data,mods{i});
end

allfiles = dir(fullfile(metadata_loc,'*.txt'));


assert(~isempty(allfiles),'No metadata files found')


for i = 1:length(allfiles)
	% read metadata.txt
	lines = strsplit(fileread([allfiles(i).folder filesep allfiles(i).name]),'\n');


	% clean up lines
	for j = 1:length(lines)
		lines{j} = regexprep(lines{j}, '\t', ' ');
		lines{j} = strip(lines{j});
	end

	this_exp = allfiles(i).name(1:end-4);
	data_idx = [];
	for j = 1:length(data)
		if strcmp(char(data(j).experiment_idx(1)),this_exp)
			data_idx = j;
		end
	end

	if isempty(data_idx)
		disp('Could not locate data...')
		continue
	end

	% make a time vector
	% assumes 20 second chunks
	time = data(data_idx).time_offset;

	for j = 2:length(data(data_idx).mask)
		if data(data_idx).filename(j) ~= data(data_idx).filename(j-1)
			time(j:end) = time(j:end) - time(j);
		end
	end

	% zero out the decentralized and modulators 
	data(data_idx).decentralized(:) = false;
	data(data_idx).RPCH(:) = 0;
	data(data_idx).proctolin(:) = 0;
	data(data_idx).CCAP(:) = 0;

	% figure out when decentralization happens
	for j = 1:length(lines)
		if isempty(lines{j})
			continue
		end

		this_line = strsplit(lines{j},' ');



		if length(this_line) == 3
			value = true; % decentralized
		elseif length(this_line) == 4
			value = str2double(this_line{4});
		else
			error('Cannot parse line')
		end

		fileid = this_line{1};
		start_time = str2double(this_line{2});
		fieldname = this_line{3};

		data = metadata.update(data, data_idx, time, start_time, fileid, fieldname, value);


	end



end


