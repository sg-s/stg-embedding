

% make sure data directory exists
filelib.mkdir('cache')

addpath(pwd)

data_dirs = {'877_093','887_081','887_005','897_005','887_049','897_037'};

data_root = '/Volumes/HYDROGEN/srinivas_data/ph-data';

if exist('cache/all_ph_data.mat','file') ~= 2

    disp('Assembling data from source...')

    
   

    if ~exist('data','var')

        for i = length(data_dirs):-1:1

            data(i) = crabsort.consolidate('neurons',{'PD'},'stack',false,'DataDir',[data_root filesep data_dirs{i}],'ChunkSize',20,'UseParallel',false, 'DataFun',{@getPH});

        end

    end

    save('cache/all_ph_data.mat','data','-v7.3')

else
    load('cache/all_ph_data.mat')
end


% ph metadata
data(1).ph_range = [5.5 10];
data(2).ph_range = [6 10];
data(3).ph_range = [5.5 9.5];
data(4).ph_range = [5.5 10];
data(5).ph_range = [5.5 10];
data(6).ph_range = [5.5 10];

% correct the raw pH readings using this metadata



% add all of this to the ISI database
for i = 1:length(data)
    thoth.add(data(i),'neurons',{'PD'});
end