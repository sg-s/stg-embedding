function data = cronin(data, metadata_loc)

allfiles = dir(pathlib.join(metadata_loc,'*.txt'));

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

	% zero out the decentralized
	data(data_idx).decentralized(:) = false;


	% figure out when decentralization happens
	for j = 1:length(lines)
		if ~isempty(strfind(lines{j},'decentralized'))
			a = j;
			break
		end
	end

	assert(~isempty(a),'Could not find decentralized in the text file')


	this_line = strsplit(lines{a},' ');

	fileid = this_line{1};
	ok = logical(0*data(data_idx).mask);
	for j = 1:length(data(data_idx).filename)
		if isempty(strfind(char(data(data_idx).filename(j)),fileid))
			continue
		end
		if str2double(this_line{2}) > time(j)
			continue
		end
		ok(j) = true;
	end

	decentralized = find(ok,1,'first');


	assert(~isempty(decentralized),'Could not determine decentralized location')

	data(data_idx).decentralized(find(ok,1,'first'):end) = true;



	



end


return


n_files = length(allfiles);

metadata.temperature = NaN(n_files,1);
metadata.decentralized = false(n_files,1);

% get the last four digits of every file name -- this will be the file identifier
file_identifiers = zeros(length(allfiles),1);
for i = 1:length(allfiles)
	z = min(strfind(allfiles(i).name,'.'));
	this_file_identifier = str2double(allfiles(i).name(z-4:z-1));
	if isnan(this_file_identifier)
		error(['Could not match numeric identifier to this file: ' allfiles(i).name])
	end
	file_identifiers(i) = this_file_identifier;
end


for i = 1:length(lines)
	
	this_line =strsplit(lines{i},' ');
	if length(this_line) < 2
		continue
	end

	file_idx = find(str2double(this_line{1}) == file_identifiers);


	if ~isnan(str2double(this_line{2})) && ~isempty(file_idx)
		% interpret as temperature
		metadata.temperature(file_idx) = str2double(this_line{2});
	
	elseif strcmp(this_line{2},'decentralized')

		% get file_idx right
		if isempty(file_idx)
			file_idx = (find(file_identifiers > str2double(this_line{1}),1,'first'));
		end

		metadata.decentralized(file_idx:end) = true;
	elseif length(this_line) == 3 && ~isnan(str2double(this_line{3}))
		% interpret this as neuromodualtor + conc

		% get file_idx right
		if isempty(file_idx)
			file_idx = (find(file_identifiers > str2double(this_line{1}),1,'first'));
		end



		neuromodulator_name = this_line{2};
		neuromodualtor_conc = str2double(this_line{3});
		if ~isfield(metadata,neuromodulator_name)
			metadata.(neuromodulator_name) = zeros(n_files,1);
		end


		metadata.(neuromodulator_name)(file_idx:end) = neuromodualtor_conc;
	end

end

