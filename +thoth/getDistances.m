% returns precomputed distances
% for the chosen experiments and ISI types

function [D, isis] = getDistances(varargin)

isi_data_dir = getpref('thoth','isi_data_dir');
isi_distance_dir = getpref('thoth','isi_distance_dir');


assert(~isempty(isi_data_dir),'isi_data_dir not set')
assert(~isempty(isi_distance_dir),'isi_distance_dir not set')

temp = dir(isi_data_dir);
options.experiments = {temp.name};
options.Variant = 4;
options.isi_types = {'PD_PD','PD_LP','LP_LP','LP_PD'};

options = corelib.parseNameValueArguments(options,varargin{:});


% unpack
experiments = options.experiments;
isi_types = options.isi_types;

assert(iscell(experiments),'experiments should be a cell array')
assert(iscell(isi_types),'isi_types should be a cell array')



% make lists of hashes of ISIs for every experiment
isi_hashes = repmat(experiments,length(isi_types),1);
for i = 1:length(experiments)
	for j = 1:length(isi_types)
		isi_files = dir([isi_data_dir filesep experiments{i} filesep isi_types{j} filesep '*.mat']);
		assert(length(isi_files)==1,'More than one ISI file found!')
		isi_hashes{j,i} = isi_files.name;
	end


end


% figure out how many points there are in each experiment
disp('Determining data size...')
fprintf('\n')

N = 0;

data_starts = NaN(length(experiments),1);
data_ends = NaN(length(experiments),1);

for i = 1:length(experiments)
	corelib.textbar(i,length(experiments))
	if strcmp(experiments{i}(1),'.')
		continue
	end

	% it doesn't matter which type we measure...the data size should be the same
	m = matfile([isi_data_dir filesep experiments{i} filesep isi_types{1} filesep isi_hashes{1,i} ]);


	data_starts(i) = N+1;
	N = N + size(m.isis,2);
	data_ends(i) = N;
end



disp(['N = ' strlib.oval(N)]);


D = zeros(N,N,length(isi_types));
isis = NaN(1e3,N,length(isi_types));



% now assemble the matrix

for i = 1:length(isi_types)

	disp(isi_types{i})
	fprintf('\n')

	this_isi_type = isi_types{i};

	for ii = 1:length(experiments)

		this_exp = experiments{ii};
		corelib.textbar(ii,length(experiments))

		if strcmp(experiments{ii}(1),'.')
			continue
		end


		% load isis
		m = matfile([isi_data_dir filesep this_exp filesep this_isi_type filesep isi_hashes{i, ii}]);
		isis(:,data_starts(ii):data_ends(ii),i) = m.isis;



		% now load the distances in parallel
		loadme = cell(length(experiments),1);

		parfor jj = 1:length(experiments) % parallelize this


			if strcmp(experiments{jj}(1),'.')
				continue
			end


			% this hash comes from the hashes of the two constituent ISI files
			H = hashlib.md5hash([isi_hashes{i,ii} isi_hashes{i,jj}]);
			H = H(1:6);



			dist_file = [isi_distance_dir filesep this_exp '_' experiments{jj} '_' this_isi_type  '_' mat2str(options.Variant) '_' H '.mat'];

			assert(exist(dist_file,'file')==2,'dist_file not found!')


			m = matfile(dist_file);


			loadme{jj} = m.D;
	

		end
		

		% now load it into the matrix
		for jj = 1:length(experiments)
			if ii == jj
				D(data_starts(ii):data_ends(ii),data_starts(jj):data_ends(jj),i) = (loadme{jj});
			else
				D(data_starts(jj):data_ends(jj),data_starts(ii):data_ends(ii),i) = transpose(loadme{jj});
			end
		end
			

	end


	D(:,:,i) = mathlib.symmetrize(D(:,:,i));



end