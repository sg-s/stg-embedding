% helper function used by thoth.measure
% and thoth.cleanup

function [D_filenames, use_isisA, use_isisB, use_type, idx] = generateFilenames(Variant)

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
