% This script makes a figure of the map
% assuming it exists, and shows illustrative examples from
% each class 

if ~exist('alldata','var')
    init()
end

% unpack
idx = alldata.idx;


cats = categories(idx);

colors = display.colorscheme(cats);

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



show_these = {'2c7515c3fb2de7b02fbe074b3ccbbe64','b9a33bc684164f7df45214e80549ae5b','b45625f4f424657001b0b42d3cebd833','450324c262e6d0985546303a3be2ddb2','2a1b3fdd81045a07bba3304dae95fc51','194d195827f25260fa79f37acfd9ff50','8fa9403320cb86b4466e6f657e50bdd5','88ffe48204b51a892b06dfc7d1f6f67f','b6c2db016a538e90d0c496d8fa0f06c4','09918b68d9c992efcde5fdcc8a7155a4','53867eae65073909c7e932837192246a','07b6748491fb2665e739afd71660a176','2025e57a047d339afdf33eb4926ce7c9'};


for i = 1:length(show_these)
    axes(ax.examples(i))

    show_this = find(strcmp(hashes.alldata,show_these{i}));

    PD = alldata.PD(show_this,:);
    LP = alldata.LP(show_this,:);
    offset = nanmin([LP(:); PD(:)]);
    PD = PD - offset;
    LP = LP - offset;
    neurolib.raster(PD,'deltat',1,'center',false)
    neurolib.raster(LP,'deltat',1,'center',false,'yoffset',1,'Color','r')
    title([char(idx(show_this)) ' (n=' mat2str(sum(idx==cats{i})) ')'],'FontWeight','normal')

    ax.examples(i).YTick = [];
    ax.examples(i).XTick = [];
    ax.examples(i).Box = 'on';
    axis(ax.examples(i),'on')
    this_color = colors(idx(show_this));
    plotlib.vertline(ax.examples(i),-.45,'Color',this_color,'LineWidth',10);
    ax.examples(i).Color = [.95 .95 .95];

end


figlib.pretty('LineWidth',1)


axlib.move(ax.examples,'right',.05)
axlib.move(ax.examples(1:2:end),'right',.05)

ax.main.Position = [.06 .1 .4 .8];
ax.examples(1).YTick = [.5 1.5];
ax.examples(1).YTickLabel = {'PD','LP'};


figlib.saveall('Location',display.saveHere)
init()