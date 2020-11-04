% this helper function fixed metadata in the Cronin data
% because we have a differnet source of metadata in a 
% different format 

function data = cronin(data)


arguments 
	data (1,1) struct
end


allfiles = dir('../annotations/cronin-metadata/*.txt');
assert(~isempty(allfiles),'No metadata files found')

disp(['Modifying metadata for cronin data... ' char(data.experiment_idx(1))])

this_name = [char(data.experiment_idx(1)) '.txt'];

use_this = find(strcmp({allfiles.name},this_name));

assert(length(use_this)==1,'Could not find metadata file!')


lines = strsplit(fileread([allfiles(use_this).folder filesep allfiles(use_this).name]),'\n');


% clean up lines
for j = 1:length(lines)
	lines{j} = regexprep(lines{j}, '\t', ' ');
	lines{j} = strip(lines{j});
end




% make a time vector
% assumes 20 second chunks
time = data.time_offset;

for j = 2:length(data.mask)
	if data.filename(j) ~= data.filename(j-1)
		time(j:end) = time(j:end) - time(j);
	end
end

% create vectors to hold metadata
N = length(data.mask);
data.decentralized = false(N,1);
data.RPCH = zeros(N,1);
data.proctolin = zeros(N,1);
data.CCAP = zeros(N,1);
data.PTX = zeros(N,1);

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

	data = metadata.update(data, time, start_time, fileid, fieldname, value);


end




