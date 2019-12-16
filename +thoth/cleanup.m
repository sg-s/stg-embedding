% deletes distance files that do not correspond to anything
% in isi_data

function cleanup()

isi_data_dir = getpref('thoth','isi_data_dir');
isi_distance_dir = getpref('thoth','isi_distance_dir');


assert(~isempty(isi_data_dir),'isi_data_dir not set')
assert(~isempty(isi_distance_dir),'isi_distance_dir not set')

existing_distance_files = dir([isi_distance_dir filesep '*.mat']);
existing_distance_files = {existing_distance_files.name};
existing_distance_hashes = existing_distance_files;


% we only care about the hash
D_filenames = thoth.generateFilenames(1);
for i = 1:length(D_filenames)
	D_filenames{i} = D_filenames{i}(end-9:end-4);
end

for i = 1:length(existing_distance_hashes)
	existing_distance_hashes{i} = existing_distance_hashes{i}(end-9:end-4);
end

purge_these = false(length(existing_distance_hashes),1);

for i = 1:length(purge_these)

	if isempty(find(strcmp(existing_distance_hashes{i}, D_filenames)))
		purge_these(i) = true;
	end


end

if any(purge_these)
	disp('not coded, need to purge old files...')
	keyboard
end