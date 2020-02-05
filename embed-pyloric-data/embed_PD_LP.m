

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


return


% % measure ISIs
% data = thoth.computeISIs(data, {'LP','PD'});

% % disallow ISIs below 10ms
% for i = 1:length(data)
%     data(i).PD_PD(data(i).PD_PD<.01) = NaN;
%     data(i).LP_LP(data(i).LP_LP<.01) = NaN;
% end




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

figure('outerposition',[300 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)

plot_this = (decentralized == 1);

ph = plot(R(plot_this,1),R(plot_this,2),'.','Color',[1 0 0],'MarkerFaceColor',[1 0 0],'MarkerSize',8);

figlib.pretty()
axis off


% color points by neuromodulator IDX
oxotremorine = vertcat(data.oxotremorine);
proctolin = vertcat(data.proctolin);
serotonin = vertcat(data.serotonin);

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



labels = unique(idx);





% show how we go silent due to different neuromodulators 

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

subplot(2,2,1); hold on

% only serotonin 
serotonin = vertcat(data.serotonin);
rm_this = ~isnan(serotonin);
J = embedding.computeTransitionMatrix(idx(~rm_this));

embedding.plotSankey(J, find(labels == 'silent'), labels);



subplot(2,2,2); hold on

% only oxo 
oxotremorine = vertcat(data.oxotremorine);
rm_this = ~isnan(oxotremorine);
J = embedding.computeTransitionMatrix(idx(~rm_this));

embedding.plotSankey(J, find(labels == 'silent'), labels);


subplot(2,2,3); hold on

% only proctolin 
proctolin = vertcat(data.proctolin);
rm_this = ~isnan(proctolin);
J = embedding.computeTransitionMatrix(idx(~rm_this));

embedding.plotSankey(J, find(labels == 'silent'), labels);



figlib.pretty




% show how we recover due to different neuromodulators 

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

subplot(2,2,1); hold on

% only serotonin 
serotonin = vertcat(data.serotonin);
rm_this = ~isnan(serotonin);
J = embedding.computeTransitionMatrix(idx(~rm_this));

embedding.plotSankey(J, find(labels == 'normal'), labels);



subplot(2,2,2); hold on

% only oxo 
oxotremorine = vertcat(data.oxotremorine);
rm_this = ~isnan(oxotremorine);
J = embedding.computeTransitionMatrix(idx(~rm_this));

embedding.plotSankey(J, find(labels == 'normal'), labels);


subplot(2,2,3); hold on

% only proctolin 
proctolin = vertcat(data.proctolin);
rm_this = ~isnan(proctolin);
J = embedding.computeTransitionMatrix(idx(~rm_this));

embedding.plotSankey(J, find(labels == 'normal'), labels);



figlib.pretty




