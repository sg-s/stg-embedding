


filelib.mkdir('cache')


% define the data we are going to work on

highk_data_dirs = {'904_054','906_120','931_016','904_051','930_037','906_126','904_066','930_045'};
ph_data_dirs = {'877_093','887_081','887_005','897_005','887_049','897_037'};

highk_data_root = '/Volumes/HYDROGEN/srinivas_data/high-k-data/intra_2_5k_PTX/use-these';
ph_data_root = '/Volumes/HYDROGEN/srinivas_data/ph-data';

data_dirs = [highk_data_dirs, ph_data_dirs];



% get the ISIs and distances
[D, isis] = thoth.getDistances(data_dirs, {'PD_PD'});



% now get the actual data and metadata


addpath('../')

ptx_start = [52, 54, 42, 50, 36, 34, 64, 42]*3;
high_k_start = [80, 86, 72, 70, 74, 74, 94, 70]*3;
high_k_end = [170, 178, 162, 160, 168, 166, 184, 160]*3;

if exist('cache/all_high_k_data.mat','file') ~= 2

    disp('Assembling data from source...')

    
  
    for i = length(highk_data_dirs):-1:1
        data(i) = crabsort.consolidate('neurons',{'PD'},'stack',true,'DataDir',[highk_data_root filesep highk_data_dirs{i}],'ChunkSize',20);
    end

    save('cache/all_high_k_data.mat','data','-v7.3')

else
    load('cache/all_high_k_data.mat')
end

% make some metadata vectors
for i = 1:length(data)
    data(i).after_ptx = logical(0*data(i).mask);
    data(i).before_highk = logical(0*data(i).mask);
    data(i).after_highk = logical(0*data(i).mask);
    data(i).after_ptx(ptx_start(i):end) = true;
    data(i).before_highk(1:high_k_start(i)) = true;
    data(i).after_highk(high_k_end(i):end) = true;
end



highk_data = data;
clear data


% get pH data

if exist('cache/all_ph_data.mat','file') ~= 2
    disp('Assembling data from source...')
    for i = length(ph_data_dirs):-1:1
        data(i) = crabsort.consolidate('neurons',{'PD'},'stack',false,'DataDir',[ph_data_root filesep ph_data_dirs{i}],'ChunkSize',20,'UseParallel',false, 'DataFun',{@getPH});
    end
    save('cache/all_ph_data.mat','data','-v7.3')
else
    load('cache/all_ph_data.mat')
end
ph_data = data;
clear data


% ph metadata
ph_data(1).ph_range = [5.5 10];
ph_data(2).ph_range = [6 10];
ph_data(3).ph_range = [5.5 9.5];
ph_data(4).ph_range = [5.5 10];
ph_data(5).ph_range = [5.5 10];
ph_data(6).ph_range = [5.5 10];

% correct the raw pH readings using this metadata
for i = 1:length(ph_data)
	ph = -ph_data(i).pH;
	ph = ph - min(ph);
	ph = ph/max(ph);

	ph = ph * diff(ph_data(i).ph_range);
	ph = ph + ph_data(i).ph_range(1);
	ph_data(i).pH = ph;
end





% harmonize the two data sets
ph_data = rmfield(ph_data, 'filename');
ph_data = rmfield(ph_data, 'ph_range');

data = structlib.merge(highk_data, ph_data);

% fill in some missing info with NaNs so we can collapse all data together
fn = fieldnames(data);
for i = 1:length(data)
	for j = 1:length(fn)
		if isempty(data(i).(fn{j}))
			data(i).(fn{j}) = NaN*data(i).mask;
		end
	end
end


% collapse all data into vectors
data = structlib.scalarify(data);

data.firing_rate = sum(~isnan(data.PD))/20;

% tsne the data 
t = TSNE; 
t.distance_matrix = D;
t.random_seed = 1990;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;


load('labels.mat')


% colour by "state"

figure('outerposition',[300 300 951 901],'PaperUnits','points','PaperSize',[951 900]); hold on


labels = (unique(idx));
C = colormaps.linspecer(9);

for i = length(labels):-1:1
    plot_this = idx == labels(i);
    plot(R(plot_this,1),R(plot_this,2),'.','MarkerSize',30,'Color',C(i,:))
end

axis off
ch.Position = [.88 .12 .01 .3];
axis tight
figlib.pretty;





% plot, colour by firing rate
figure('outerposition',[300 300 951 901],'PaperUnits','points','PaperSize',[951 900]); hold on


[~,ch] = plotlib.cplot(R(:,1),R(:,2),data.firing_rate,'clim',[0 10],'colormap','colormaps.redula');
title(ch,'Firing rate (Hz)')
axis off
ch.Position = [.88 .12 .01 .3];
axis tight
figlib.pretty;



% plot, colour by prep IDX
figure('outerposition',[300 300 951 901],'PaperUnits','points','PaperSize',[951 900]); hold on

preps =  unique(data.experiment_idx);
C = [lines(8); colormaps.linspecer(6)];

for i = 1:length(preps)
    plot_this = data.experiment_idx == preps(i);
    plot(R(plot_this,1),R(plot_this,2),'.','MarkerSize',10,'Color',C(i,:))
end


axis off
axis tight
figlib.pretty;






% colour by pH, and indicate high K

figure('outerposition',[300 300 951 901],'PaperUnits','points','PaperSize',[951 900]); hold on

C = [.8 .8 .8];
ch = plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20);



[~,ch] = plotlib.cplot(R(:,1),R(:,2),data.pH,'colormap','colormaps.redblue');
title(ch, 'pH')

plot_this = data.after_highk == false & data.before_highk == false;
C = [0 .5 .0];
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',10)


axis off
ch.Position = [.88 .12 .01 .3];
axis tight
figlib.pretty;






% before and after high K

figure('outerposition',[300 300 951 901],'PaperUnits','points','PaperSize',[951 900]); hold on


C = [.8 .8 .8];
ch = plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20);


% plot before high k in black dots
plot_this = data.before_highk == true & data.after_ptx == true;
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',12)

% plot after high k in red
plot_this = (data.after_highk == true);
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',12)


axis off
title('Before and after high K')

figlib.pretty
pdflib.snap





% colour by experiment


figure('outerposition',[300 300 951 901],'PaperUnits','points','PaperSize',[951 900]); hold on
all_exp_id = (data.experiment_idx);
u = unique(all_exp_id);
c = colormaps.linspecer(length(u));
for i = 1:length(u)
    plot(R(all_exp_id==u(i),1),R(all_exp_id==u(i),2),'.','MarkerFaceColor',c(i,:),'MarkerEdgeColor',c(i,:),'MarkerSize',20)
end
axis off
title('Coloured by experiment ID')

figlib.pretty
pdflib.snap





% show trajectories prep-by-prep (pH)
preps =  unique(data.experiment_idx);


figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[951 900]); hold on



idx = 1;
for i = 1:length(preps)

    if ~any(~isnan(data.pH(data.experiment_idx == preps(i))))
        continue
    end

    subplot(2,3,idx); hold on
    C = [.8 .8 .8];
    plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)



    plot(R(data.experiment_idx==preps(i),1),R(data.experiment_idx==preps(i),2),'Color',[1 .7 .7])
    plot(R(data.experiment_idx==preps(i),1),R(data.experiment_idx==preps(i),2),'.','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10)
    axis square
    axis off

    idx = idx + 1;


end

figlib.pretty()
pdflib.snap()








% show trajectories prep-by-prep (high K)
preps =  unique(data.experiment_idx);

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[951 900]); hold on

plotidx = 1;
for i = 1:length(preps)

    if any(~isnan(data.pH(data.experiment_idx == preps(i))))
        continue
    end

    subplot(3,3,plotidx); hold on
    C = [.8 .8 .8];
    plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)


    plot(R(data.experiment_idx==preps(i),1),R(data.experiment_idx==preps(i),2),'Color',[1 .7 .7])
    plot(R(data.experiment_idx==preps(i),1),R(data.experiment_idx==preps(i),2),'.','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10)
    axis square
    axis off

    plotidx = plotidx + 1;


end

figlib.pretty()
pdflib.snap()


return



% build transition matrix for all data
% also compute marginal transition probabilites for differnet perturbations



labels = unique(idx);
N = length(labels);
J = zeros(N);
J_ph = 0*J;
J_k = 0*J;

idx2 = circshift(idx,1);


J = embedding.computeTransitionMatrix(idx);


% only high K
temp = idx;
temp(~isnan(data.pH)) = categorical({'Undefined'});
J_k = embedding.computeTransitionMatrix(temp);

% only pH
temp = idx;
temp(isnan(data.pH)) = categorical({'Undefined'});
J_ph = embedding.computeTransitionMatrix(temp);

% compute per-prep-transition matrices
for i = 1:length(preps)
    temp = idx;
    temp(data.experiment_idx == preps(i)) = [];
    J_prep(:,:,i) = embedding.computeTransitionMatrix(temp);
end


% show all three transition matrices 
figure('outerposition',[300 300 1200 1100],'PaperUnits','points','PaperSize',[1200 1100]); hold on
clear ax

ax(1) = subplot(2,2,1); hold on
imagesc((J))
caxis([0 .3])

ax(2) = subplot(2,2,3); hold on
imagesc((J_k))
caxis([0 .3])

ax(3) = subplot(2,2,4); hold on
imagesc((J_ph))
caxis([0 .3])

for i = 1:3

    set(ax(i),'XTickLabelRotation',45)
    set(ax(i),'XTickLabels',corelib.categorical2cell(labels))

    set(ax(i),'YTickLabels',corelib.categorical2cell(labels))
    set(ax(i),'YTickLabelRotation',45)
    axis(ax(i),'square')
    set(ax(i),'XLim',[0 length(labels)+1],'YLim',[0 length(labels)+1])
    set(ax(i),'XTick',1:length(labels))
    set(ax(i),'YTick',1:length(labels))
    box(ax(i),'on')

end
colormap(parula)

figlib.pretty
ax(1).Position(1) = .37;


% show how we end up in a regular bursting state. 
figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

subplot(2,1,1); hold on
embedding.plotSankey(J_ph, find(labels == 'regular-bursting'), labels)

subplot(2,1,2); hold on
embedding.plotSankey(J_k, find(labels == 'regular-bursting'), labels)

figlib.pretty





% show how we go silent

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

subplot(2,1,1); hold on
embedding.plotSankey(J_ph, find(labels == 'silent'), labels);

subplot(2,1,2); hold on
embedding.plotSankey(J_k, find(labels == 'silent'), labels);

figlib.pretty






% show prep-by-prep variation in going silent
% do the pH preps, because there are 6 of them
figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

clear ax
plotidx = 1;
for i = 1:length(preps)
    if any(isnan(data.pH(data.experiment_idx == preps(i))))
        continue
    end


    ax(plotidx) = subplot(2,3,plotidx); hold on
    [th_feeder, th_end] = embedding.plotSankey(J_prep(:,:,i), find(labels == 'silent'), labels);

    if rem(plotidx,3) == 1

    else
        delete(th_feeder)
    end

    if rem(plotidx,3) == 0
    else
        delete(th_end)
    end

    plotidx = plotidx + 1;
end


figlib.pretty;

for i = 1:length(ax)
    ax(i).Position(3) = .25;
    ax(i).XLim = [-3 0];
    drawnow
end






% does crash trajectroy depend on pH?
% compare pH<6 and ph>9.5 (two extreme groups)

% build transition matrices based on pH
temp = idx;
temp(data.pH > 6) = [];
J_low_ph = embedding.computeTransitionMatrix(temp);

temp = idx;
temp(data.pH < 9.5) = [];
J_hi_ph = embedding.computeTransitionMatrix(temp);



figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

subplot(2,1,1); hold on
embedding.plotSankey(J_low_ph, find(labels == 'silent'), labels);

subplot(2,1,2); hold on
embedding.plotSankey(J_hi_ph, find(labels == 'silent'), labels);

figlib.pretty












% measure switching rates by pH
% plot state by pH
all_ph = data.pH;

N = 31; % how many bins along pH?
ph_space =  linspace(5.5,10,N);

switching_rate = NaN*ph_space;


% this matrix counts states
state_dist = zeros(N-1,length(labels));


for i = 1:N-1
    this_ph = all_ph >= ph_space(i) & all_ph <= ph_space(i+1);

    % find states in this ph bin
    for j = 1:length(labels)
        state_dist(i,j) = sum(idx(this_ph) == labels(j));
    end

    % norm
    state_dist(i,:) = state_dist(i,:)/sum(state_dist(i,:));

    these_states = idx(this_ph);
    these_states2 = circshift(these_states,1);

    switching_rate(i) = 1 -  mean(these_states == these_states2);

end












return

%this is what I used to manually label the clusters
f = figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
ax = gca;

M = clusterlib.manual('ReducedData',R,'RawData',isis); 
M.idx = idx;
M.makeUI;
M.MouseCallback = @(x) plotRaster(x, ax);
