
% make sure data directory exists
filelib.mkdir('cache')

exp_ids = {'828_144_2','828_104_1','828_144_1','828_042'};

if exist('cache/spike_times.mat','file') ~= 2

    disp('Assembling data from source...')

    data_root = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding';
    


    if ~exist('data','var')

        for i = length(exp_ids):-1:1

            data{i} = crabsort.consolidate('neurons',{'PD','LP'},'DataDir',[data_root filesep exp_ids{i}],'ChunkSize',20);

        end

    end

    save('cache/spike_times.mat','data','-v7.3')

else
    load('cache/spike_times.mat')
end

return

% add all of this to the ISI database
for i = 1:length(data)
    thoth.add(data{i},'neurons',{'PD','LP'});
end


% Assume that the distances are computed on a cluster, and you have access
% to the data...

[D, isis] = thoth.getDistances(exp_ids, {'PD_PD','PD_LP','LP_LP','LP_PD'});

D = sum(D,3);
u = umap; u.metric = 'precomputed';
R = u.fit(D);

