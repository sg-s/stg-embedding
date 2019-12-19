

%% In this document, I will embed spikes from PD and LP
% during perturbations into a single map

%%
% The data I will use is from the following experiments:


data_dirs = {'828_001_1','828_034_1','828_104_1','828_128','857_010','857_012','857_052','857_080','857_104','877_093','887_005','887_049','887_081','889_142','892_147','897_005','897_037','901_151','901_154','904_018','906_126','930_045','857_006','828_136_1','828_042_2'};


% make sure data directory exists
filelib.mkdir('cache')


if exist('cache/PD_LP.mat','file') ~= 2

    data_root = getpref('crabsort','store_spikes_here');
    all_dirs = filelib.getAllFolders(data_root);

    disp('Assembling data from source...')
  
    for i = length(data_dirs):-1:1

        disp(data_dirs{i})

        % find out where this file is
        this_dir = all_dirs(filelib.find(all_dirs,data_dirs{i}));
        [~, pick_this] = max(cellfun(@(x) strfind(x, data_dirs{i})-length(x),this_dir));
        


        data(i) = crabsort.consolidate('neurons',{'PD','LP'},'stack',true,'DataDir',this_dir{pick_this},'ChunkSize',20);
    end

    save('cache/PD_LP.mat','data','-v7.3')

else
    load('cache/PD_LP.mat')
end



% measure ISIs
data = thoth.computeISIs(data, {'LP','PD'});

% disallow ISIs below 10ms
for i = 1:length(data)
    data(i).PD_PD(data(i).PD_PD<.01) = NaN;
    data(i).LP_LP(data(i).LP_LP<.01) = NaN;
end




% add all of this to the ISI database
for i = 1:length(data)
    thoth.add(data(i),'neurons',{'PD','LP'});
end




% Assume that the distances are precomputed....

[D, isis] = thoth.getDistances('isi_types', {'PD_PD','PD_LP','LP_LP','LP_PD'},'experiments',data_dirs,'Variant',4);


eD = sum(D,3);



SubSample = 1;

t = TSNE; 
t.perplexity = 500;
t.Alpha = .7;
t.DistanceMatrix = eD(1:SubSample:end,1:SubSample:end);
t.NIter  = 500;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;

mdata = struct;
mdata.LP = data(1).LP';
mdata.PD = data(1).PD';

for i = 2:length(data)
    mdata.LP = vertcat(mdata.LP, data(i).LP');
    mdata.PD = vertcat(mdata.PD, data(i).PD');
end

% subsample
mdata.LP = mdata.LP(1:SubSample:end,:);
mdata.PD = mdata.PD(1:SubSample:end,:);





explore


return




% measure the burst metrics of LP and PD for every point here
mdata = measureBurstMetrics(mdata);

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
plot(R(:,1),R(:,2),'.','Color',[.5 .5 .5])

ok = mdata.LP_burst_period > .5 & mdata.LP_burst_period < 1.5 & mdata.PD_burst_period > .5 & mdata.PD_burst_period < 1.5;
plot(R(ok,1),R(ok,2),'r.')



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

