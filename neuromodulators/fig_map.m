% This script makes a figure of the map
% assuming it exists, and shows illustrative examples from
% each class 

cats = corelib.categorical2cell(unique(idx));

clear ax
figure('outerposition',[300 300 2000 999],'PaperUnits','points','PaperSize',[2000 999]); hold on

pidx = 1;
for i = 1:3
    for j = 1:7
        ax.examples(pidx) = subplot(7,3,pidx); hold on
        
        set(ax.examples(pidx),'YLim',[-.01 2.01],'XLim',[-.5 10])
        pidx = pidx + 1;
    end
end

ax.main = subplot(1,3,1); hold on
axis off
ax.examples = ax.examples(isvalid(ax.examples));


plot(ax.main,R(:,1),R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)
for i = 1:length(cats)
    plot(ax.main,R(idx==cats{i},1),R(idx==cats{i},2),'.','Color',colors(cats{i}),'MarkerSize',10)
    axis square
end


show_these = [5353 1798 7880 2748 6956 6482 6899 5059 8668 5669 7671 1765 6522 4764]

for i = 1:length(show_these)
    axes(ax.examples(i))
    PD = alldata.PD(show_these(i),:);
    LP = alldata.LP(show_these(i),:);
    offset = nanmin([LP(:); PD(:)]);
    PD = PD - offset;
    LP = LP - offset;
    neurolib.raster(PD,'deltat',1,'center',false)
    neurolib.raster(LP,'deltat',1,'center',false,'yoffset',1,'Color','r')
    title([char(idx(show_these(i))) ' (n=' mat2str(sum(idx==cats{i})) ')'],'FontWeight','normal')

    ax.examples(i).YTick = [];
    ax.examples(i).XTick = [];
    ax.examples(i).Box = 'on';
    axis(ax.examples(i),'on')
    this_color = colors(idx(show_these(i)));
    plotlib.vertline(ax.examples(i),-.45,'Color',this_color,'LineWidth',10);
    ax.examples(i).Color = [.95 .95 .95];

end


figlib.pretty('LineWidth',1)


axlib.move(ax.examples,'right',.05)
axlib.move(ax.examples(1:2:end),'right',.05)

ax.main.Position = [.06 .1 .4 .8];
ax.examples(1).YTick = [.5 1.5];
ax.examples(1).YTickLabel = {'PD','LP'};

