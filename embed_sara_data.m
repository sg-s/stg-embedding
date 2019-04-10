

% specify data files to work with:
data_files = {'828_001_1',...
              '828_042',...
              '828_128',...
              '857_016',...
              '857_020_1',...
              '857_104',...
              '857_080'};

data_dir = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding/';

if ~exist('data','var')
	for i = 1:length(data_files)
		data{i} =  crabsort.consolidate('neurons',{'LP','PD'},'DataDir',[data_dir data_files{i}],'stack',true,'ChunkSize',20);
	end
end                                                                                                  

thoth.add(data,'neurons',{'LP','PD'})