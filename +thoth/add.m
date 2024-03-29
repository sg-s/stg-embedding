% adds data created by crabsort.consolidate to the 
% the global ISI database
% data must be a scalar structure containing
% chunked data (use the "ChunkSIze" option)
function add(data, varargin)


isi_data_dir = getpref('thoth','isi_data_dir');
isi_distance_dir = getpref('thoth','isi_distance_dir');


options.neurons = {};


options = corelib.parseNameValueArguments(options,varargin{:});

assert(~isempty(options.neurons),'Neurons not defined')

neurons = options.neurons;



filelib.mkdir(isi_data_dir)


% save in DB


expid = data.experiment_idx(1);
exp_dir = [isi_data_dir filesep char(expid)];
filelib.mkdir(exp_dir)


for ii = 1:length(neurons)
	for jj = 1:length(neurons)


		fn = [neurons{ii} '_' neurons{jj}];

		filelib.mkdir([exp_dir filesep fn])

		isis = data.(fn);

		H = hashlib.md5hash(isis);

		% check that no file already exists there
		old_files = dir([exp_dir filesep fn filesep '*.mat']);
		for i = 1:length(old_files)
			delete([old_files(i).folder filesep old_files(i).name])
		end

		save([exp_dir filesep fn filesep H '.mat'],'isis','-nocompression')

	end
end


