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

% compute ISIs for all data

data = thoth.computeISIs(data, neurons);


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

		save([exp_dir filesep fn filesep 'isis.mat'],'isis','-nocompression')

	end
end


