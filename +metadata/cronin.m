% script that adds on metadata for the cronin data

function data = cronin(data)

arguments
	data (1,1) embedding.DataStore
end



allfiles = dir('../annotations/cronin-metadata/*.txt');


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

	assert(any(data.experiment_idx == this_exp),'Could not find this experiment in the cronin data')

	these_pts = find(data.experiment_idx == this_exp);


	% make a time vector
	time = data.time_offset(these_pts);


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

		file_ok = these_pts(cellfun(@(x) any(strfind(x,fileid)),corelib.categorical2cell(data.filename(these_pts))));
		a = file_ok(find(start_time < data.time_offset(file_ok) ,1,'first'));


		data.(fieldname)(a:these_pts(end)) = value;

	end



end


