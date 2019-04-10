% returns precomputed distances
% for the chosen experiments and ISI types

function D = getDistances(experiments, isi_types)




isi_data_dir = getpref('thoth','isi_data_dir');
isi_distance_dir = getpref('thoth','isi_distance_dir');


assert(~isempty(isi_data_dir),'isi_data_dir not set')
assert(~isempty(isi_distance_dir),'isi_distance_dir not set')


assert(iscell(experiments),'experiments should be a cell array')
assert(iscell(isi_types),'isi_types should be a cell array')

if isempty(experiments)
	% get all experiments
	experiments = dir(isi_data_dir);
	experiments = {experiments.name};
end


% figure out how many points there are in each experiment
N = 0;

data_starts = NaN(length(experiments),1);
data_ends = NaN(length(experiments),1);

for i = 1:length(experiments)
	if strcmp(experiments{i}(1),'.')
		continue
	end

	
	m = matfile([isi_data_dir filesep experiments{i} filesep isi_types{1} filesep 'isis.mat']);

	data_starts(i) = N+1;
	N = N + size(m.isis,2);
	data_ends(i) = N;
end

D = zeros(N,N,length(isi_types));

% now assemble the matrix

for i = 1:length(isi_types)

	for ii = 1:length(experiments)


		if strcmp(experiments{ii}(1),'.')
			continue
		end

		for jj = 1:length(experiments)


			if strcmp(experiments{jj}(1),'.')
				continue
			end

			dist_file = [isi_distance_dir filesep experiments{ii} filesep isi_types{i} filesep experiments{jj} '.mat'];

			assert(exist(dist_file,'file')==2,'dist_file not found!')

			m = matfile(dist_file);

			if ii == jj
				D(data_starts(ii):data_ends(ii),data_starts(jj):data_ends(jj)) = (m.D);
			else
				D(data_starts(jj):data_ends(jj),data_starts(ii):data_ends(ii)) = transpose(m.D);
			end


		end

	end




end