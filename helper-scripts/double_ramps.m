% convert all data into .crab

data_root = '/Volumes/DATA/734_148';

cd(data_root)



% % first, flatten the directroy
% ! yes | find .  -mindepth 2 -type f -exec mv -i '{}' . ';' 



% remove some junk
allfiles = dir(data_root);
for i = 1:length(allfiles)
	if strcmp(allfiles(i).name(1),'.')
		continue
	end
	[~,~,ext]= fileparts(allfiles(i).name);
	if strcmpi(ext,'.smr')
		continue
	end
	if strcmpi(ext,'.abf')
		continue
	end
	if strcmpi(ext,'.crab')
		continue
	end

	if isdir(allfiles(i).name)
		rmdir(allfiles(i).name,'s')
	else
		delete(allfiles(i).name)
	end

	
end


% % now reconstitute them into experiments
% allfiles = dir(data_root);
% for i = 1:length(allfiles)
% 	if strcmp(allfiles(i).name(1),'.')
% 		continue
% 	end

% 	if isdir([allfiles(i).folder filesep allfiles(i).name])
% 		continue
% 	end

% 	corelib.textbar(i,length(allfiles))

% 	exp_name = allfiles(i).name(1:7);
% 	filelib.mkdir(exp_name);
% 	movefile(allfiles(i).name,[exp_name filesep allfiles(i).name])
% end






alldata = dir(data_root);

for i = 1:length(alldata)

	if strcmp(alldata(i).name(1),'.')
		continue
	end

	if ~isdir([alldata(i).folder filesep alldata(i).name])
		continue
	end

	cd([alldata(i).folder filesep alldata(i).name])

	crabsort.convert2crabFormat


end