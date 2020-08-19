% This script makes a figure of the map
% assuming it exists, and shows illustrative examples from
% each class 

init

% unpack
idx = alldata.idx;



cats = categories(idx);

colors = display.colorscheme(cats);

clear ax
figure('outerposition',[300 300 2000 999],'PaperUnits','points','PaperSize',[2000 999]); hold on

pidx = 1;
for i = 1:3
    for j = 1:5
        ax.examples(pidx) = subplot(5,3,pidx); hold on
        
        set(ax.examples(pidx),'YLim',[-.01 6.01],'XLim',[-.5 10])
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


show_these_states = dictionary;
show_these_states.normal = [1888 41282];
show_these_states.('LP-silent-PD-bursting') = [31773 25244];
show_these_states.('PD-silent-LP-bursting') = [36034 32041];
show_these_states.('aberrant-spikes') = [25346 33573];
show_these_states.('interrupted-bursting') = [29486 13255];
show_these_states.irregular = [47580 30426];
show_these_states.('LP-skipped-bursts') = [42062 5547];
show_these_states.('LP-weak-skipped') = [43599 18080];
show_these_states.('PD-weak-skipped') = [27110 34743];
show_these_states.('LP-PD-01') = [26569 37344];




fn = show_these_states.keys;

for i = 1:length(ax.examples)
    axes(ax.examples(i))

    show_these = show_these_states.(fn{i});

    Y = 0;

    for j = 1:2

        PD = alldata.PD(show_these(j),:);
        LP = alldata.LP(show_these(j),:);
        offset = nanmin([LP(:); PD(:)]);
        PD = PD - offset;
        LP = LP - offset;
        neurolib.raster(PD,'deltat',1,'center',false,'yoffset',Y,'LineWidth',1)
        neurolib.raster(LP,'deltat',1,'center',false,'yoffset',Y+1,'Color','r','LineWidth',1)
        

        Y = Y + 3;

    end

    title([char(idx(show_these(1))) ' (n=' mat2str(sum(idx==fn{i})) ')'],'FontWeight','normal')

    

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
clearvars -except alldata data R burst_metrics