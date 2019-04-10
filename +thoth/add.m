% adds data created by crabsort.consolidate to the 
% the global ISI database
function add(data, varargin)

options.neurons = {};


options = corelib.parseNameValueArguments(options,varargin{:});

assert(~isempty(options.neurons),'Neurons not defined')

neurons = options.neurons;

% compute ISIs for all data

parfor i = 1:length(data)
	data{i} = thoth.computeISIs(data{i}, neurons);
end


filelib.mkdir('~/isi_data')


% save in DB

for i = 1:length(data)
	expid = data{i}.experiment_idx(1);
	exp_dir = ['~/isi_data' filesep mat2str(expid)];
	filelib.mkdir(exp_dir)


	for ii = 1:length(neurons)
		for jj = 1:length(neurons)


			fn = [neurons{ii} '_' neurons{jj}];

			filelib.mkdir([exp_dir filesep fn])

			isis = data{i}.(fn);

			save([exp_dir filesep fn filesep 'isis.mat'],'isis','-nocompression')

		end
	end



end
