
% make sure data directory exists
filelib.mkdir('cache')


data_root = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding';
avail_exps = dir(data_root);
exp_ids = {};
neurons = {'PD','LP'};

    
% automatically figure out the usable data
for i = 1:length(avail_exps)
    if strcmp(avail_exps(i).name(1),'.')
        continue
    end
    allfiles = dir([avail_exps(i).folder filesep avail_exps(i).name filesep '*.crabsort']);

    if length(allfiles) < 3
        % can't be any data here
        continue
    end

    not_sorted = crabsort.checkSorted(allfiles, neurons, true);

    if ~not_sorted
        exp_ids{end+1} = avail_exps(i).name;
    end

end

hash = hashlib.md5hash([exp_ids{:}]);


if exist(['cache/'  hash '.mat'],'file') ~= 2

    disp('Assembling data from source...')


    for i = length(exp_ids):-1:1

        data{i} = crabsort.consolidate('neurons',{'PD','LP'},'DataDir',[data_root filesep exp_ids{i}],'ChunkSize',20);

    end

    save(['cache/'  hash '.mat'],'data','-v7.3')

else
    load(['cache/'  hash '.mat'])
end


data(cellfun(@isempty,data)) = [];

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

