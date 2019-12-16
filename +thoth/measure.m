% measures distances for all data
% Usage:
%
% thoth.measure
%

function measure(Variant)

if nargin == 0
	Variant = 4;
end



isi_data_dir = getpref('thoth','isi_data_dir');
isi_distance_dir = getpref('thoth','isi_distance_dir');


assert(~isempty(isi_data_dir),'isi_data_dir not set')
assert(~isempty(isi_distance_dir),'isi_distance_dir not set')

allexp = dir(isi_data_dir);


% remove junk
rm_this = false(length(allexp),1);
for i = 1:length(rm_this)
	if strcmp(allexp(i).name(1),'.')
		rm_this(i) = true;
	end
end
allexp(rm_this) = [];


% look in every experimental folder and determine all ISI types
all_types = {};
for i = 1:length(allexp)
	these_types = dir([allexp(i).folder filesep allexp(i).name]);
	all_types = unique([all_types {these_types.name}]);
end

% remove junk
rm_this = cellfun(@(x) strcmp(x(1),'.'),all_types);
all_types(rm_this) = [];

% make a list of all things to measure and what to use
D_filenames = cell(length(allexp)*length(allexp)*length(all_types),1);
use_isisA = cell(length(allexp)*length(allexp)*length(all_types),1);
use_isisB = cell(length(allexp)*length(allexp)*length(all_types),1);
use_type = cell(length(allexp)*length(allexp)*length(all_types),1);

idx = 1;
for i = 1:length(allexp)
	for j = 1:length(allexp)
		for k = 1:length(all_types)

			isi_file1 = dir([allexp(i).folder filesep allexp(i).name filesep all_types{k} filesep '*.mat']);
			isi_file2 = dir([allexp(j).folder filesep allexp(j).name filesep all_types{k} filesep '*.mat']);


			if isempty(isi_file1)
				continue
			end

			if isempty(isi_file2)
				continue
			end

			% this hash comes from the hashes of the two constituent ISI files
			H = hashlib.md5hash([isi_file1.name isi_file2.name]);
			H = H(1:6);

			D_filenames{idx} = [allexp(i).name '_' allexp(j).name '_' all_types{k} '_' mat2str(Variant) '_' H '.mat'];

			use_isisA{idx} = allexp(i).name;
			use_isisB{idx} = allexp(j).name;
			use_type{idx} = all_types{k};


			idx = idx + 1;
		end
	end
end








% check if these files need doing, and if they do, do them
% make headers for verbose reporting
fprintf('\n')
fprintf(strlib.fix('Exp A',20))
fprintf(strlib.fix('Exp B',20))
fprintf(strlib.fix('Type',20))
fprintf(strlib.fix('STATUS',30))
fprintf('\n')
for i = 1:80
	fprintf('-')
end


tic;
actually_done_counter = 1;

for i = 1:idx-1

	fprintf('\n')
	fprintf(strlib.fix(use_isisA{i},20))
	fprintf(strlib.fix(use_isisB{i},20))
	fprintf(strlib.fix(use_type{i},20))

	if exist([isi_distance_dir filesep D_filenames{i}],'file') == 2
		fprintf(strlib.fix('Already done',30))
		continue
	end

	% need to measure this
	


	% estimate time remaining

    t_elapsed = toc;
    t_rem = (t_elapsed/actually_done_counter)*(idx-i);
    fprintf(strlib.fix(['Computing...,' strlib.oval(t_rem) 's left'],30))



	% load isisA
	load_me = dir([isi_data_dir filesep use_isisA{i} filesep use_type{i} filesep '*.mat']);
	assert(length(load_me)==1,'More than one ISI file found!')
	load([load_me.folder filesep load_me.name],'isis')
	isisA = isis;


	% load isisB
	load_me = dir([isi_data_dir filesep use_isisB{i} filesep use_type{i} filesep '*.mat']);
	assert(length(load_me)==1,'More than one ISI file found!')
	load([load_me.folder filesep load_me.name],'isis')
	isisB = isis;


	% measure distances
	D = neurolib.ISIDistance(isisA,isisB,Variant);
	save([isi_distance_dir filesep D_filenames{i}],'D');

	for j = 1:30
		fprintf('\b')
	end

	

	fprintf(strlib.fix('DONE!',30))

	actually_done_counter = actually_done_counter + 1;


end


fprintf('\n')


return


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
				D = neurolib.ISIDistance(isis,[],Variant);
				save(dist_file,'D','H');
				disp('DONE saving.')
			end
		else
			disp('No distance file, will compute...')
			clear D
			D = neurolib.ISIDistance(isis,[],Variant);
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
					D = neurolib.ISIDistance(isisA,isisB,Variant);
					save(dist_file,'D','H');
					disp('DONE saving.')
				end

			else
				
				corelib.cprintf('green','Computing...')

				% measure distances
				D = neurolib.ISIDistance(isisA,isisB,Variant);

				corelib.cprintf('green','\b\b\b\b\b\b\b\b\b\b\b\b')

				save(dist_file,'D','H');

				corelib.cprintf('green','DONE!\n')

			end


		end
	end

end