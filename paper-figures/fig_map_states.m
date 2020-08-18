% This script makes a figure of the map
% assuming it exists, and shows illustrative examples from
% each class 

if ~exist('alldata','var')
    init()
end

% unpack
idx = alldata.idx;

% get the embedding
if ~exist('R','var')
    [p,NormalizedMetrics, VectorizedData] = alldata.vectorizeSpikes2;

    fitData = VectorizedData;

    % original
    u = umap('min_dist',1, 'metric','euclidean','n_neighbors',75,'negative_sample_rate',25);
    u.labels = alldata.idx;
    R = u.fit(fitData);
end




cats = categories(idx);

colors = display.colorscheme(cats);

clear ax
figure('outerposition',[300 300 2000 999],'PaperUnits','points','PaperSize',[2000 999]); hold on

pidx = 1;
for i = 1:3
    for j = 1:6
        ax.examples(pidx) = subplot(6,3,pidx); hold on
        
        set(ax.examples(pidx),'YLim',[-.01 10.01],'XLim',[-.5 10])
        pidx = pidx + 1;
    end
end

ax.main = subplot(1,3,1); hold on
axis off
ax.examples = ax.examples(isvalid(ax.examples));


plot(ax.main,R(:,1),R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)
for i = length(cats):-1:1
    plot(ax.main,R(idx==cats{i},1),R(idx==cats{i},2),'.','Color',colors(cats{i}),'MarkerSize',10)
    
end
axis square



show_these_states.aberrant_spikes = [19150 5455 2354];
show_these_states.interrupted_bursting = [10483 7132 17823];
show_these_states.irregular = [18505 19535 18577];
show_these_states.irregular_bursting = [4964 608 2331];
show_these_states.LP_irregular_bursting = [2745 5473 20556];
show_these_states.LP_skipped_bursts = [2691 1908 9619];
show_these_states.LP_weak_skipped = [3944 20555 19851];
show_these_states.normal = [8711 1230 15671];
show_these_states.PD_skipped_bursts = [10662 17167 2011];
show_these_states.PD_weak_skipped = [14080 15347 13999];
show_these_states.phase_distrubed = [2229 3662 18412];
show_these_states.LP_silent_PD_bursting = [11200 2730 20932];
fn = fieldnames(show_these_states);

for i = 1:length(ax.examples)
    axes(ax.examples(i))

    show_these = show_these_states.(fn{i});

    Y = 0;

    for j = 1:3

        PD = alldata.PD(show_these(j),:);
        LP = alldata.LP(show_these(j),:);
        offset = nanmin([LP(:); PD(:)]);
        PD = PD - offset;
        LP = LP - offset;
        neurolib.raster(PD,'deltat',1,'center',false,'yoffset',Y,'LineWidth',1)
        neurolib.raster(LP,'deltat',1,'center',false,'yoffset',Y+1,'Color','r','LineWidth',1)
        

        Y = Y + 4;

    end

    title([char(idx(show_these(1))) ' (n=' mat2str(sum(idx==cats{i})) ')'],'FontWeight','normal')

    

    ax.examples(i).YTick = [];
    ax.examples(i).XTick = [];
    ax.examples(i).Box = 'on';
    axis(ax.examples(i),'on')
    this_color = colors(idx(show_these(1)));
    plotlib.vertline(ax.examples(i),-.45,'Color',this_color,'LineWidth',10);
    ax.examples(i).Color = [.95 .95 .95];

end


figlib.pretty('LineWidth',1)


axlib.move(ax.examples,'right',.05)
axlib.move(ax.examples(1:2:end),'right',.05)

ax.main.Position = [.06 .1 .4 .8];
ax.examples(1).YTick = [.5 5.5];
ax.examples(1).YTickLabel = {'PD','LP'};

% clean up workspace
clearvars -except alldata data VectorizedData R metricsPD metricsLP