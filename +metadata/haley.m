function data = haley(data)

arguments
	data (1,1) struct
end



% read the raw data and extract pH information
hash = structlib.md5hash(data);
cachename =  ['../annotations/ph/' structlib.md5hash(data) '.ph'];
if exist(cachename,'file') == 2
	load(cachename,'-mat')
else


	data_loc = crabsort.open(char(data.experiment_idx(1)),true);

	allfiles = dir([data_loc.folder filesep '*.crab']);

	phdata = struct;
	disp('Loading all data...')
	for i = 1:length(allfiles)
		corelib.textbar(i,length(allfiles))
		load(fullfile(allfiles(i).folder,allfiles(i).name),'-mat')
		channel = find(strcmp(builtin_channel_names,'pH'));
		phdata(i).pH = raw_data(1:floor(1/dt):end,channel); % 1 s resolution
		phdata(i).filename = allfiles(i).name;
	end

	save(cachename,'phdata')
end


% now modify the pH in the structure we are given
data.pH = NaN*data.mask;
for i = 1:length(phdata)
	[~,filename] = fileparts(phdata(i).filename);
	write_here = find(data.filename == filename);
	ph = phdata(i).pH(1:20:end);
	ph(end) = [];
	if length(ph) ~= length(write_here)
		keyboard
	end
	data.pH(write_here) = ph;

end


