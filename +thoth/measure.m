% measures distances for all data
% Usage:
%
% thoth.measure
%

function measure()

isi_data_dir = getpref('thoth','isi_data_dir');
isi_distance_dir = getpref('thoth','isi_distance_dir');


assert(~isempty(isi_data_dir),'isi_data_dir not set')
assert(~isempty(isi_distance_dir),'isi_distance_dir not set')

allexp = dir(isi_data_dir);


% first do within-experiment distances
all_isis_types = {};
for i = 1:length(allexp)

	if strcmp(allexp(i).name(1),'.')
		continue
	end

	if ~(allexp(i).isdir)
		continue
	end


	disp(allexp(i).name)



	% get the ISI types
	all_types = dir([allexp(i).folder filesep allexp(i).name]);

	for j = 1:length(all_types)

		if strcmp(all_types(j).name(1),'.')
			continue
		end

		if ~(all_types(j).isdir)
			continue
		end

		all_isis_types = [all_isis_types all_types(j).name];

		% load the isis file
		isis_file = [all_types(j).folder filesep all_types(j).name filesep 'isis.mat'];
		assert(exist(isis_file,'file')==2,['isis file not found: ' isis_file])


		clear isis
		load(isis_file)

		clear H
		H = hashlib.md5hash(isis);

		% check if this distance file already exists 
		filelib.mkdir( [isi_distance_dir filesep allexp(i).name])
		filelib.mkdir([isi_distance_dir filesep allexp(i).name filesep all_types(j).name])
		dist_file =  [isi_distance_dir filesep allexp(i).name filesep all_types(j).name filesep allexp(i).name '.mat'];

		if exist(dist_file,'file') == 2
			disp('Distance file already exists...')
			m = matfile(dist_file);
			if strcmp(H,m.H)
				disp('Hashes match, skipping...')
			else
				disp('Hash mismatch! Will recompute distances')
				clear D
				D = neurolib.ISIDistance(isis);
				save(dist_file,'D','H');
				disp('DONE saving.')
			end
		else
			disp('No distance file, will compute...')
			clear D
			D = neurolib.ISIDistance(isis);
			save(dist_file,'D','H');
			disp('DONE saving.')
		end

	end

end


% now do the cross-experiment distances
all_isis_types = unique(all_isis_types);

for i = 1:length(all_isis_types)

	disp(all_isis_types{i})

	for ii = 1:length(allexp)


		if strcmp(allexp(ii).name(1),'.')
			continue
		end

		if ~(allexp(ii).isdir)
			continue
		end

		% load this isis files
		isis_file = [isi_data_dir filesep allexp(ii).name filesep all_isis_types{i} filesep 'isis.mat'];
		if exist(isis_file,'file')~=2
			disp('No ISIs file, skipping...')
			continue
		end


		clear isis
		load(isis_file)
		isisA = isis;

		for jj = 1:length(allexp)

			if ii == jj
				continue
			end

			if strcmp(allexp(jj).name(1),'.')
				continue
			end

			if ~(allexp(jj).isdir)
				continue
			end


			fprintf(['   ' allexp(ii).name '   ' allexp(jj).name '   '])


			% load the other ISIs file
			isis_file = [isi_data_dir filesep allexp(jj).name filesep all_isis_types{i} filesep 'isis.mat'];

			if exist(isis_file,'file')~=2
				disp('No ISIs file, skipping...')
				continue
			end

			clear isis
			load(isis_file)
			isisB = isis;


			% check if this file already exists
			dist_file =  [isi_distance_dir filesep allexp(ii).name filesep all_isis_types{i} filesep allexp(jj).name '.mat'];

			clear H
			H = [hashlib.md5hash(isisA) hashlib.md5hash(isisB)];

			if exist(dist_file,'file') == 2
				corelib.cprintf('green','OK...\n')
				m = matfile(dist_file);
				if strcmp(H,m.H)
					% disp('Hashes match, skipping...')
				else
					disp('Hash mismatch! Will recompute distances')
					clear D
					D = neurolib.ISIDistance(isisA,isisB);
					save(dist_file,'D','H');
					disp('DONE saving.')
				end

			else
				
				corelib.cprintf('green','Computing...')

				% measure distances
				D = neurolib.ISIDistance(isisA,isisB);

				corelib.cprintf('green','\b\b\b\b\b\b\b\b\b\b\b\b')

				save(dist_file,'D','H');

				corelib.cprintf('green','DONE!\n')

			end


		end
	end

end