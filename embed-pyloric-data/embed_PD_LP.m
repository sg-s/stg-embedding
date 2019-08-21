

%% In this document, I will embed spikes from PD and LP
% during perturbations into a single map

%%
% The data I will use is from the following experiments:


data_dirs = {'877_093','887_005','887_049','887_081','889_142','892_147','897_005','897_037','901_151','901_154','904_018','906_126','930_045'};

data_root = '/Volumes/HYDROGEN/srinivas_data';
all_dirs = filelib.getAllFolders(data_root);

% make sure data directory exists
filelib.mkdir('cache')


if exist('cache/PD_LP.mat','file') ~= 2

    disp('Assembling data from source...')
  
    for i = length(data_dirs):-1:1

        disp(data_dirs{i})

        % find out where this file is
        this_dir = all_dirs(filelib.find(all_dirs,data_dirs{i}));
        [~, pick_this] = max(cellfun(@(x) strfind(x, data_dirs{i})-length(x),this_dir));
        


        data(i) = crabsort.consolidate('neurons',{'PD','LP'},'stack',false,'DataDir',this_dir{pick_this},'ChunkSize',20);
    end

    save('cache/PD_LP.mat','data','-v7.3')

else
    load('cache/PD_LP.mat')
end



% add all of this to the ISI database
for i = 1:length(data)
    thoth.add(data(i),'neurons',{'PD','LP'});
end







% Assume that the distances are computed on a cluster, and you have access
% to the data...

[D, isis] = thoth.getDistances(data_dirs, {'PD_PD','PD_LP','LP_LP','LP_PD'});


% exxagerate delays between neurons 
D2 = D;
D2(:,:,2) = 1*D(:,:,2);
D2(:,:,4) = 1*D(:,:,4);

eD = sum(D2,3);

SubSample = 10;

eD = eD(1:SubSample:end,1:SubSample:end);


t = TSNE; 
t.distance_matrix = eD;
t.n_iter  = 1000;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;

mdata = struct;
mdata.LP = data(1).LP';
mdata.PD = data(1).PD';

for i = 2:length(data)
    mdata.LP = vertcat(mdata.LP, data(i).LP');
    mdata.PD = vertcat(mdata.PD, data(i).PD');
end

mdata.LP = mdata.LP(1:SubSample:end,:);
mdata.PD = mdata.PD(1:SubSample:end,:);

explore