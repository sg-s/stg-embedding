
% this script prepares ISI files that thoth can run on and measure distances

% global parameters
ChunkSize = 20; % seconds

data_dir = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding/';

data_files = filelib.folders(data_dir);



for i = 1:length(data_files)



	allfiles = dir([data_dir data_files(i).name filesep '*.crabsort']);
	
	if length(allfiles) == 0
		continue
	end


	fatal = crabsort.checkSorted(allfiles,{'LP','PD'});

	if fatal
		continue
	end


	clc
	disp(data_files(i).name)


	% chunk data without stacking
	data =  crabsort.consolidate('neurons',{'LP','PD'},'DataDir',[data_dir data_files(i).name],'stack',false,'ChunkSize',ChunkSize);

	thoth.add(data,'neurons',{'LP','PD'})
end
                                                                                           



