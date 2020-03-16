

%% In this document, I will embed spikes from PD and LP
% during perturbations into a single map

%%
% The data I will use is from the following experiments:


data_dirs = {'828_001_1','828_034_1','828_104_1','828_128','857_010','857_012','857_052','857_080','857_104','877_093','887_005','887_049','887_081','889_142','892_147','897_005','897_037','901_151','901_154','904_018','906_126','930_045','857_006','828_136_1','828_042_2'};


% make sure data directory exists
filelib.mkdir('cache')

data_root = '/Volumes/DATA/srinivas_data/embedding_data/';

if exist('cache/PD_LP.mat','file') ~= 2

    

    disp('Assembling data from source...')
  
    for i = length(data_dirs):-1:1

        disp(data_dirs{i})

        data{i} = crabsort.consolidate('neurons',{'PD','LP'},'stack',true,'DataDir',[data_root data_dirs{i}],'ChunkSize',20);
    end

    data = structlib.cell2array(data);

    save('cache/PD_LP.mat','data','-v7.3')

else
    load('cache/PD_LP.mat')
end


% get pH data
for i = 1:length(data_dirs)
    if exist([data_root data_dirs{i} filesep 'pH.mat'],'file') == 2
        load([data_root data_dirs{i} filesep 'pH.mat'])
        data(i).pH = pH;
        assert(length(pH) == size(data(i).PD,2),'Data sizes do not match');
    else
        data(i).pH = [];
    end
end




% fill in empty metadata
fn = fieldnames(data);
for i = 1:length(data)
    for j = 1:length(fn)
        if isempty(data(i).(fn{j}))
            N = size(data(i).LP,2);
            data(i).(fn{j}) = NaN(N,1);
        end
    end
end


% clean up the potassium
for i = 1:length(data)
    data(i).Potassium(isnan(data(i).Potassium)) = 1;
    data(i).Potassium((data(i).Potassium)==0) = 1;
    data(i).TimeInHighK = NaN*data(i).Potassium;
end

% create time in high K vectors
for i = 1:length(data)
    K = data(i).Potassium;

    if all(K==1)
        continue
    end



    [ons, offs]=veclib.computeOnsOffs(K);


    K_time = NaN*K;

    for j = 1:length(ons)
        K_time(ons(j)-20:offs(j)) = (1:(offs(j) -  ons(j) + 21)) - 20;
    end

    data(i).TimeInHighK = K_time*20; % now in seconds
    

end



% approximate temperatures using linear interpolation
for i = 1:length(data)
    if all(isnan(data(i).temperature))
        continue
    end
    temp = data(i).temperature;
    x = 1:length(temp);
    temp(isnan(temp)) = interp1(x(~isnan(temp)),temp(~isnan(temp)),x(isnan(temp)));
    data(i).temperature = temp;

end



return


% measure ISIs
data = thoth.computeISIs(data, {'LP','PD'});

% disallow ISIs below 10ms
for i = 1:length(data)
    data(i).PD_PD(data(i).PD_PD<.01) = NaN;
    data(i).LP_LP(data(i).LP_LP<.01) = NaN;
end



% combine all data
types = {'PD_PD','LP_LP','LP_PD','PD_LP'};
cdata = struct;
cdata.LP = data(1).LP';
cdata.PD = data(1).PD';

for j = 1:length(types)
    cdata.(types{j}) = data(1).(types{j})';
end

for i = 2:length(data)
    cdata.LP = vertcat(cdata.LP, data(i).LP');
    cdata.PD = vertcat(cdata.PD, data(i).PD');

    for j = 1:length(types)
        cdata.(types{j}) = vertcat(cdata.(types{j}), data(i).(types{j})');
    end

end






% compute cumulative histograms for all ISIs
clear cdfs
N = size(cdata.LP,1);
nbins = 100;
bins = logspace(-3,1,nbins+1);
for i = 1:length(types)
    cdfs.(types{i}) = NaN(N,nbins);

    for j = 1:N
        temp = cdata.(types{i})(j,:);
        temp(isnan(temp)) = [];
        if isempty(temp)
            continue
        end

        cdfs.(types{i})(j,:) = histcounts(temp,bins,'Normalization','cdf');
    end

end


% measure distances using earth mover distance
% naive form of earth-mover distance
D = zeros(N,N);
W = diff(bins);
tic
for isi = 1:4
    disp(types{isi})
    A = cdfs.(types{isi});
    D = D + thoth.EarthMoverDistance(A);
    
end
toc



t = TSNE('implementation',TSNE.implementation.fitsne);
t.DistanceMatrix = D;
t.perplexity = 500;
t.Alpha = .7;
R = t.fit;


% % add all of this to the ISI database
% for i = 1:length(data)
%     thoth.add(data(i),'neurons',{'PD','LP'});
% end




% % Assume that the distances are precomputed....

% [D, isis] = thoth.getDistances('isi_types', {'PD_PD','PD_LP','LP_LP','LP_PD'},'experiments',data_dirs,'Variant',4);


% eD = sum(D,3);



SubSample = 1;

% t = TSNE; 
% t.perplexity = 500;
% t.Alpha = .7;
% t.DistanceMatrix = eD(1:SubSample:end,1:SubSample:end);
% t.NIter  = 500;
% t.implementation = TSNE.implementation.vandermaaten;
% R = t.fit;


% assume data is embedded, now load
load('P_500_Alpha_0.7.mat')
load('idx.mat')


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




% show examples 

show_these = [461 10478 10106 2802 8597 12356 442 3402 1476 6174 13277 11620];

figure('outerposition',[300 300 1501 1100],'PaperUnits','points','PaperSize',[1501 1100]); hold on

labels = categories(idx);

for i = 1:12
    subplot(6,2,i); hold on
    PD = mdata.PD(show_these(i),:);
    LP = mdata.LP(show_these(i),:);
    a = nanmin([PD LP]);
    PD = PD - a;
    LP = LP - a;
    neurolib.raster(LP,'yoffset',0,'deltat',1,'center',false,'Color','k') 
    neurolib.raster(PD,'yoffset',1,'deltat',1,'center',false,'Color','r') 
    set(gca,'XLim',[0 10],'YLim',[0 2])
    axis off
    N = sum(idx == labels{i+1});
    title([labels{i+1} ' (n = ' strlib.oval(N) ')'],'FontWeight','normal')
end
figlib.pretty()




% color points by pH
pH = vertcat(data.pH);

figure('outerposition',[300 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)


plot_this = ~isnan(pH);
phidx = pH(~isnan(pH));

sh = scatter(R(plot_this,1),R(plot_this,2),24,phidx,'filled');

colormap(colormaps.redblue)

figlib.pretty()
axis off

ch = colorbar;
ch.Position = [.85 .6 .01 .35];
title(ch,'pH')




% color map by temperature
temperature = vertcat(data.temperature);
bin_edges = linspace(11,31,21);

figure('outerposition',[300 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)


C = colormaps.redula(20);
for i = 1:length(bin_edges)-1
    plot_this = temperature >= bin_edges(i) & temperature < bin_edges(i+1);
    plot(R(plot_this,1),R(plot_this,2),'Color',C(i,:),'MarkerSize',10,'LineStyle','none','Marker','.')
end
ch = colorbar;
colormap(C)
figlib.pretty()
axis off
ch.Position = [.1 .5 .02 .4];
caxis([11 31])

% color points by experiment ID

exp_idx = vertcat(data.experiment_idx);
N = length(categories(exp_idx));
cats = categories(exp_idx);
C = lines(N);
M = reshape(repmat({'+','x','.','^'},7,1),28,1);


figure('outerposition',[300 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)

for i = 1:N
    plot_this = exp_idx == cats(i);
    plot(R(plot_this,1),R(plot_this,2),'Color',C(i,:),'MarkerSize',5,'Marker',M{i},'LineStyle','none')
end

figlib.pretty()
axis off



% color points by decentralized or not
decentralized = vertcat(data.decentralized);
oxotremorine = vertcat(data.oxotremorine);
proctolin = vertcat(data.proctolin);
serotonin = vertcat(data.serotonin);

decentralized(isnan(decentralized)) = 0;
oxotremorine(isnan(oxotremorine)) = 0;
proctolin(isnan(proctolin)) = 0;
serotonin(isnan(serotonin)) = 0;

decentralized = logical(decentralized) & oxotremorine == 0 & proctolin == 0 & serotonin == 0;

figure('outerposition',[300 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)

plot_this = (decentralized == 1);

ph = plot(R(plot_this,1),R(plot_this,2),'.','Color',[1 0 0],'MarkerFaceColor',[1 0 0],'MarkerSize',8);

figlib.pretty()
axis off


% color points by neuromodulator IDX


figure('outerposition',[300 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)

plot_this = (oxotremorine > 0);
ph = plot(R(plot_this,1),R(plot_this,2),'.','Color',[1 0 0],'MarkerFaceColor',[1 0 0],'MarkerSize',12);

plot_this = (proctolin > 0);
ph = plot(R(plot_this,1),R(plot_this,2),'x','Color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',8);

plot_this = (serotonin > 0);
ph = plot(R(plot_this,1),R(plot_this,2),'+','Color',[0 0 1],'MarkerFaceColor',[0 0 1],'MarkerSize',8);

figlib.pretty()
axis off





% time in high K -- switching rate and state distribution

N = 80;
bin_edges = linspace(-380,5400,N);
bin_centers = bin_edges(2:end) + mean(diff(bin_edges));

% this matrix counts states
labels = categories(idx);

switching_rate = NaN(N-1,1);
state_dist = zeros(N-1, length(categories(idx)));

K_time = vertcat(data.TimeInHighK);

for i = 1:N-1
    this_time = K_time >= bin_edges(i) & K_time <= bin_edges(i+1);

    % find states in this ph bin
    for j = 1:length(labels)
        state_dist(i,j) = sum(idx(this_time) == labels(j));
    end

    % norm
    state_dist(i,:) = state_dist(i,:)/sum(state_dist(i,:));

    these_states = idx(this_time);
    these_states2 = circshift(these_states,1);

    switching_rate(i) = 1 -  mean(these_states == these_states2);

end





figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

clear ax
ax(1) = subplot(2,1,1); hold on
bar(bin_centers, switching_rate,'EdgeColor','w','FaceColor',[.7 .7 .7])
set(gca,'XTickLabel',{})
ylabel('Switching rate')

ax(2) = subplot(2,1,2); hold on

C = colormaps.dcol(13);

bh = bar(bin_centers/60, state_dist,'stacked');
for i = 1:length(bh)
    bh(i).EdgeColor = C(i,:);
    bh(i).FaceColor = C(i,:);
    bh(i).BarWidth = 1;
end
bh(end).EdgeColor = 'k';
bh(end).FaceColor = 'k';

set(gca,'YLim',[0 1])
xlabel('Time in high K (min)')
ylabel('States')
set(gca,'YTickLabel',{})


legend(labels,'Location','eastoutside')

figlib.pretty()

ax(1).Position(3) = ax(2).Position(3);





















% measure switching rates by pH
% plot state by pH


ph_space = 5.5:.05:10.4;

N = length(ph_space);

% this matrix counts states
labels = categories(idx);
state_dist = zeros(N-1, length(categories(idx)));

switching_rate = NaN*ph_space;

buffer_overflow = .25;

ph = vertcat(data.pH);

for i = 1:N-1
    this_time = ph >= ph_space(i) - buffer_overflow & pH <= ph_space(i+1) + buffer_overflow;

    % find states in this ph bin
    for j = 1:length(labels)
        state_dist(i,j) = sum(idx(this_time) == labels(j));
    end

    % norm
    state_dist(i,:) = state_dist(i,:)/sum(state_dist(i,:));

    these_states = idx(this_time);
    these_states2 = circshift(these_states,1);

    switching_rate(i) = 1 -  mean(these_states == these_states2);

end




figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

clear ax
ax(1) = subplot(2,1,1); hold on
bar(ph_space, switching_rate,'EdgeColor','w','FaceColor',[.7 .7 .7])
set(gca,'XTickLabel',{})
ylabel('Switching rate')

ax(2) = subplot(2,1,2); hold on

C = colormaps.dcol(13);

bh = bar(ph_space(2:end), state_dist,'stacked');
for i = 1:length(bh)
    bh(i).EdgeColor = C(i,:);
    bh(i).FaceColor = C(i,:);
    bh(i).BarWidth = 1;
end
bh(end).EdgeColor = 'k';
bh(end).FaceColor = 'k';

set(gca,'YLim',[0 1])
xlabel('pH')
ylabel('States')
set(gca,'YTickLabel',{})


legend(labels,'Location','eastoutside')

figlib.pretty()

ax(1).Position(3) = ax(2).Position(3);













% build transition matrix for all data
% also compute marginal transition probabilites for differnet perturbations







% show the likelihood of being in different states for different neuromodulators 

all_labels = unique(idx);
C = colormaps.dcol(length(unique(idx)));



figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

% decentralized
subplot(2,2,1); hold on
title('decentralized')
plot_this = decentralized > 0;
labels = unique(idx(plot_this));
y = histcounts(idx(plot_this));
y = y/sum(y);
for i = 1:length(all_labels)
    barh(i,y(i),'FaceColor',C(i,:))
end
set(gca,'YTick',1:length(all_labels),'YTickLabel',categories(all_labels),'XLim',[0 .8])


% serotonin
subplot(2,2,2); hold on
title('serotonin')
plot_this = serotonin > 0;
labels = unique(idx(plot_this));
y = histcounts(idx(plot_this));
y = y/sum(y);
for i = 1:length(all_labels)
    barh(i,y(i),'FaceColor',C(i,:))
end
set(gca,'YTick',1:length(all_labels),'YTickLabel','','XLim',[0 .8])

% proctolin
subplot(2,2,3); hold on
title('proctolin')
plot_this = proctolin > 0;
labels = unique(idx(plot_this));
y = histcounts(idx(plot_this));
y = y/sum(y);
for i = 1:length(all_labels)
    barh(i,y(i),'FaceColor',C(i,:))
end
set(gca,'YTick',1:length(all_labels),'YTickLabel',categories(all_labels),'XLim',[0 .8])


% oxotremorine
subplot(2,2,4); hold on
title('oxotremorine')
plot_this = oxotremorine > 0;
labels = unique(idx(plot_this));
y = histcounts(idx(plot_this));
y = y/sum(y);
for i = 1:length(all_labels)
    barh(i,y(i),'FaceColor',C(i,:))
end
set(gca,'YTick',1:length(all_labels),'YTickLabel','','XLim',[0 .8])


figlib.pretty()




labels = unique(idx);
% show how we go PD-silent due to different neuromodulators 

figure('outerposition',[300 300 1333 999],'PaperUnits','points','PaperSize',[1333 999]); hold on


% decentralized 
subplot(2,2,1); hold on
J = embedding.computeTransitionMatrix(idx(decentralized > 0));
embedding.plotSankey(J, find(labels == 'PD-silent'), labels);
title('decentralized')


% only serotonin 
subplot(2,2,2); hold on
J = embedding.computeTransitionMatrix(idx(serotonin>0));
embedding.plotSankey(J, find(labels == 'PD-silent'), labels);
title('serotonin')

% only proctolin 
subplot(2,2,3); hold on
J = embedding.computeTransitionMatrix(idx(proctolin>0));
embedding.plotSankey(J, find(labels == 'PD-silent'), labels);
title('proctolin')


% only oxo 
subplot(2,2,4); hold on
J = embedding.computeTransitionMatrix(idx(oxotremorine>0));
embedding.plotSankey(J, find(labels == 'PD-silent'), labels);
title('oxotremorine')

figlib.pretty




% show how we recover due to different neuromodulators + decentralized 



figure('outerposition',[300 300 1333 999],'PaperUnits','points','PaperSize',[1333 999]); hold on


% decentralized 
subplot(2,2,1); hold on
J = embedding.computeTransitionMatrix(idx(decentralized > 0));
embedding.plotSankey(J, find(labels == 'normal'), labels);
title('decentralized')


% only serotonin 
subplot(2,2,2); hold on
J = embedding.computeTransitionMatrix(idx(serotonin>0));
embedding.plotSankey(J, find(labels == 'normal'), labels);
title('serotonin')

% only proctolin 
subplot(2,2,3); hold on
J = embedding.computeTransitionMatrix(idx(proctolin>0));
embedding.plotSankey(J, find(labels == 'normal'), labels);
title('proctolin')


% only oxo 
subplot(2,2,4); hold on
J = embedding.computeTransitionMatrix(idx(oxotremorine>0));
embedding.plotSankey(J, find(labels == 'normal'), labels);
title('oxotremorine')

figlib.pretty









% compare how preps go silent due to different perurbations



figure('outerposition',[300 300 1333 999],'PaperUnits','points','PaperSize',[1333 999]); hold on

subplot(2,2,1); hold on
K_time = vertcat(data.TimeInHighK);
J = embedding.computeTransitionMatrix(idx(K_time > 0));
embedding.plotSankey(J, find(unique(idx) == 'silent'), labels);
title('High extracellular K')

subplot(2,2,2); hold on
J = embedding.computeTransitionMatrix(idx(decentralized));
embedding.plotSankey(J, find(unique(idx) == 'silent'), labels);
title('Decentralization')


pH = vertcat(data.pH);
altered_pH = (0*pH);
altered_pH(isnan(altered_pH)) = 0;
altered_pH = logical(altered_pH);
altered_pH(pH<7.5) = true;
altered_pH(pH>8.5) = true;


subplot(2,2,3); hold on
J = embedding.computeTransitionMatrix(idx(altered_pH));
embedding.plotSankey(J, find(unique(idx) == 'silent'), labels);
title('Altered pH')


% high temperature, intact prep
all_temp = vertcat(data.temperature);


subplot(2,2,4); hold on
J = embedding.computeTransitionMatrix(idx(all_temp > 20 & ~decentralized));
embedding.plotSankey(J, find(unique(idx) == 'silent'), labels);
title('>20C')

figlib.pretty()





% prep to variability in going silent with pH 
prep_idx = vertcat(data.experiment_idx);
pH_preps = unique(prep_idx(altered_pH));

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

for i = 1:length(pH_preps)
    subplot(2,3,i); hold on
    J = embedding.computeTransitionMatrix(idx(prep_idx == pH_preps(i)));
    embedding.plotSankey(J, find(unique(idx) == 'normal'), labels);
    title(['Prep #' mat2str(i)])
end

figlib.pretty()




% prep to prep variability in decentralized preps 
prep_idx = vertcat(data.experiment_idx);
decentralized_preps = unique(prep_idx(decentralized));

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
show_these = [1 2 4 7 9 10];
for i = 1:length(show_these)
    subplot(2,3,i); hold on
    J = embedding.computeTransitionMatrix(idx(prep_idx == decentralized_preps(show_these(i))));
    th_feeder = embedding.plotSankey(J, find(unique(idx) == 'silent'), labels);
    title(['Prep #' mat2str(i)])

end

figlib.pretty()