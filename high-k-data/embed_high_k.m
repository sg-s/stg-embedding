% make sure data directory exists
filelib.mkdir('cache')

data_dirs = {'904_054','906_120','931_016','904_051','930_037','906_126','904_066','930_045'};

if exist('cache/all_high_k_data.mat','file') ~= 2

    disp('Assembling data from source...')

    data_root = '/Volumes/HYDROGEN/srinivas_data/high-k-data/intra_2_5k_PTX/use-these';
    

    ptx_start = [52, 54, 42, 50, 36, 34, 64, 42];
    high_k_start = [80, 86, 72, 70, 74, 74, 94, 70];
    high_k_end = [170, 178, 162, 160, 168, 166, 184, 160];

    if ~exist('data','var')

        for i = length(data_dirs):-1:1

            data(i) = crabsort.consolidate('neurons',{'PD'},'stack',true,'DataDir',[data_root filesep data_dirs{i}],'ChunkSize',20);

        end

    end

    save('cache/all_high_k_data.mat','data','-v7.3')

else
    load('cache/all_high_k_data.mat')
end

% add all of this to the ISI database
for i = 1:length(data)
    thoth.add(data(i),'neurons',{'PD'});
end


% Assume that the distances are computed on a cluster, and you have access
% to the data...

[D, isis] = thoth.getDistances(data_dirs, {'PD_PD'});

u = umap; u.metric = 'precomputed';
R = u.fit(D);