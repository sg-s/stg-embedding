

%% In this document, I will embed spikes from PD and LP
% during perturbations into a single map

%%
% The data I will use is from the following experiments:


data_dirs = {'877_093','887_005','887_049','887_081','889_142','892_147','897_005','897_037','901_151','901_154','904_018','906_126','930_045'};



% make sure data directory exists
filelib.mkdir('cache')


if exist('cache/PD_LP.mat','file') ~= 2

    data_root = '/Volumes/HYDROGEN/srinivas_data';
    all_dirs = filelib.getAllFolders(data_root);

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

% for i = 1:length(data)
%     thoth.add(data(i),'neurons',{'PD','LP'});
% end







% Assume that the distances are computed on a cluster, and you have access
% to the data...


[D, isis] = thoth.getDistances(data_dirs, {'PD_PD','PD_LP','LP_LP','LP_PD'});

if exist('cache/distances_isis.mat','file') ~= 2
    [D, isis] = thoth.getDistances(data_dirs, {'PD_PD','PD_LP','LP_LP','LP_PD'});
    save('cache/distances_isis.mat','D','isis')
elseif exist('D','var') ~= 1
    load('cache/distances_isis.mat','D','isis')
end

% cutoff large distances
D(D>10) = 10;

% also add a distance that depends on the firing rate
LP_inverse_f = 1./sum(~isnan([data.LP]));
PD_inverse_f = 1./sum(~isnan([data.PD]));

Df = squareform(pdist([LP_inverse_f; PD_inverse_f]'));
Df(isinf(Df)) = max(Df(~isinf(Df)));
Df(isnan(Df)) = max(Df(~isinf(Df)));

SubSample = 2;
SD = D(1:SubSample:end,1:SubSample:end,:);
Df = Df(1:SubSample:end,1:SubSample:end,:);



eD = (sum(SD,3));

=======


SubSample = 2;

SD = D(1:SubSample:end,1:SubSample:end,:);

eD = sum(SD,3);

t = TSNE; 
t.perplexity = 120;
t.distance_matrix = eD;
t.n_iter  = 500;
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



%%
% now we bin ISIs and simply t-SNE them and see what we get
n_bins = 50;
binned_isis = zeros(n_bins,size(isis,2),4);
bin_edges = linspace(0,1,n_bins+1);
bin_centers = bin_edges(1:end-1) + mean(diff(bin_edges))/2;
for i = 1:size(isis,2)
    for j = 1:4
        binned_isis(:,i,j) = histcounts(isis(:,i,j),bin_edges);
    end
end

% weight each bin by the center of the bin
for i = 1:4
    for j = 1:size(binned_isis,2)
        binned_isis(:,j,i) = (binned_isis(:,j,i)').*bin_centers;
    end
end


% normalize 
% for i = 1:4
%     for j = 1:size(binned_isis,2)
%         binned_isis(:,j,i) = binned_isis(:,j,i)/sum(binned_isis(:,j,i));
%     end
% end

% rearranged isis and stack different dimensions
%explore





% approximate methods -- create the binned isi matrix
n_bins = 30;
isi_bin_edges = logspace(-2,0,n_bins+1);
binned_isis = zeros(n_bins,size(isis,2),4);
bin_centers = isi_bin_edges(1:end-1)+diff(isi_bin_edges)/2;
for i = 1:4
    for j = 1:size(isis,2)
        temp = histcounts(isis(:,j,i),isi_bin_edges);
        binned_isis(:,j,i) = bin_centers.*temp;
        % normalize
        binned_isis(:,j,i) =  binned_isis(:,j,i)/sum( binned_isis(:,j,i));
    end
end

% reshape
temp = zeros(n_bins*4,size(isis,2));
for i = 1:4
    temp(n_bins*(i-1)+1:n_bins*i,:) = binned_isis(:,:,i);
end
binned_isis = temp;


binned_isis(isnan(binned_isis)) = 0;


% subsample
binned_isis = binned_isis(:,1:SubSample:end);


% remove NaNs
binned_isis(isnan(binned_isis)) = 0;

t = TSNE; 
t.perplexity = 120;
t.raw_data = binned_isis;
t.n_iter  = 500;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;




% now let's try NMF
[W,H] = nnmf(binned_isis,10);


t = TSNE; 
t.perplexity = 30;
t.raw_data = H;
t.n_iter  = 500;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;

% use seqNMF
[W,H,cost, loadings,power] = seqNMF(binned_isis>0,'lambdaOrthoH',1,'showPlot',1,'L',1,'K',20);

% use NMF on this matrix
[W,H] = nnmf(binned_isis,20);

