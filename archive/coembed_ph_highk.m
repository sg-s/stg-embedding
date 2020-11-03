


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




% figure out time after high k
data.time_in_high_k = NaN*data.mask;
preps =  unique(data.experiment_idx);

for i = 1:length(preps)
    this_prep = data.experiment_idx == preps(i);
    if any(~isnan(data.pH(this_prep)))
        continue
    end

    temp = (data.after_highk == false & data.before_highk == false);
    temp = temp(this_prep);
    time_in_high_k = (1:length(temp)) - find(temp,1,'first');
    time_in_high_k(find(temp,1,'last'):end) = NaN;

    data.time_in_high_k(this_prep) = time_in_high_k;

end

data.time_in_high_k = data.time_in_high_k*20; % now in seconds


















% colour by "state" and show example rasters of each state

labels = (unique(idx));
C = lines;
C(8,:) = [0 0 0];

examples = [11, 120, 138, 30; 8057, 8462, 8177, 6250; 5393, 1349, 583, 559; 1055, 911, 3340, 961; 6372, 2177, 1598, 1599; 4729, 2201, 2129, 7713; 4671, 1561, 2174, 1552]; 

for j = 1:size(examples,1)



    figure('outerposition',[300 300 1200 900],'PaperUnits','points','PaperSize',[1200 900]); hold on

    subplot(4,1,1:3); hold on
    axis square



    for i = length(labels):-1:1
        plot_this = idx == labels(i);
        plot(R(plot_this,1),R(plot_this,2),'.','MarkerSize',30,'Color',C(i,:))
    end

    axis off
    axis tight

    % show examples
    subplot(4,1,4); hold on

    this_color = find(labels == idx(examples(j,1)));
    this_color = C(this_color,:);
    this_color = repmat(this_color,4,1);

    neurolib.raster(data.PD(:,examples(j,:)),'split_rows',true,'Color',this_color,'deltat',1,'LineWidth',2)

    axis off
    figlib.pretty;



end
















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

figlib.pretty
pdflib.snap















% show trajectories prep-by-prep (pH)

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[951 900]); hold on

plotidx = 1;
for i = 1:length(preps)

    if ~any(~isnan(data.pH(data.experiment_idx == preps(i))))
        continue
    end

    subplot(2,3,plotidx); hold on
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










% show trajectories prep-by-prep (high K)


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




% build transition matrix for all data
% also compute marginal transition probabilites for differnet perturbations



labels = unique(idx);
idx2 = circshift(idx,1);


J = embedding.computeTransitionMatrix(idx);


% only high K
rm_this = ~isnan(data.pH) | data.time_in_high_k < 0 | isnan(data.time_in_high_k);
J_k = embedding.computeTransitionMatrix(idx(~rm_this));

% only pH
J_ph = embedding.computeTransitionMatrix(idx(~isnan(data.pH)));

% compute per-prep-transition matrices
for i = length(preps):-1:1
    J_prep(:,:,i) = embedding.computeTransitionMatrix(idx(data.experiment_idx == preps(i)));
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
embedding.plotSankey(J_ph, find(labels == 'regular-bursting'), labels);

subplot(2,1,2); hold on
embedding.plotSankey(J_k, find(labels == 'regular-bursting'), labels);

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










% show prep-by-prep variation in going silent
% now the high K preps
figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

clear ax
plotidx = 1;
for i = 1:length(preps)
    if ~any(isnan(data.pH(data.experiment_idx == preps(i))))
        continue
    end


    ax(plotidx) = subplot(3,3,plotidx); hold on
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
embedding.plotSankey(J_low_ph, find(labels == 'regular-bursting'), labels);

subplot(2,1,2); hold on
embedding.plotSankey(J_hi_ph, find(labels == 'regular-bursting'), labels);

figlib.pretty











% measure switching rates by pH
% plot state by pH


ph_space = 5.5:.02:10;

N = length(ph_space);

 % this matrix counts states
state_dist = zeros(N-1,length(labels));

switching_rate = NaN*ph_space;

buffer_overflow = .25;

for i = 1:N-1
    this_time = data.pH >= ph_space(i) - buffer_overflow & data.pH <= ph_space(i+1) + buffer_overflow;

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
plot(ph_space, switching_rate,'ko')
set(gca,'XTickLabel',{})
ylabel('Switching rate')

ax(2) = subplot(2,1,2); hold on

bh = bar(ph_space(2:end), state_dist,'stacked');
for i = 1:length(bh)
    bh(i).EdgeColor = bh(i).FaceColor;
    bh(i).BarWidth = 1;
end
bh(end).EdgeColor = 'k';
bh(end).FaceColor = 'k';

set(gca,'YLim',[0 1])
xlabel('pH')
ylabel('States')
set(gca,'YTickLabel',{})


legend(corelib.categorical2cell(labels),'Location','eastoutside')

figlib.pretty()

ax(1).Position(3) = ax(2).Position(3);




















% plot states as a funciton of time in high K
time_in_high_k_space = -500:20:6000;

N = length(time_in_high_k_space);

 % this matrix counts states
state_dist = zeros(N-1,length(labels));

switching_rate = NaN*time_in_high_k_space;

buffer_overflow = 100;

for i = 1:N-1
    this_time = data.time_in_high_k >= time_in_high_k_space(i) - buffer_overflow & data.time_in_high_k <= time_in_high_k_space(i+1) + buffer_overflow;

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
plot(time_in_high_k_space, switching_rate,'ko')
set(gca,'XTickLabel',{})
ylabel('Switching rate')

ax(2) = subplot(2,1,2); hold on

bh = bar(time_in_high_k_space(2:end)/60, state_dist,'stacked');
for i = 1:length(bh)
    bh(i).EdgeColor = bh(i).FaceColor;
    bh(i).BarWidth = 1;
end
bh(end).EdgeColor = 'k';
bh(end).FaceColor = 'k';

set(gca,'YLim',[0 1])
xlabel('Time since high K onset (min)')
ylabel('States')
set(gca,'YTickLabel',{})


legend(corelib.categorical2cell(labels),'Location','eastoutside')

figlib.pretty()

ax(1).Position(3) = ax(2).Position(3);







return

%this is what I used to manually label the clusters
f = figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
ax = gca;

M = clusterlib.manual('ReducedData',R,'RawData',isis); 
M.idx = idx;
M.makeUI;
M.MouseCallback = @(x) plotRaster(x, ax);
