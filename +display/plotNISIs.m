% plots a whole bunch of PD-PD, LP-LP, and LP-PD
% ISIs to get a sense of the data
% useful when plotting only some clusters
% to get a sense of what activity in that cluster
% looks like

function plotNISIs(ax,alldata,N,idx)

arguments
	ax (1,1) matlab.graphics.axis.Axes {isvalid}
	alldata (1,1) embedding.DataStore
	N (1,1) double
	idx (1,1) categorical 
end

% drawing constants
Alpha = .2;
Spacing = 1e4;
colors = display.colorscheme(alldata.idx);

LP_color = color.aqua('red');
PD_color = color.aqua('indigo');
delay_color = [.3 .3 .3];


use_these = find(alldata.idx == idx);
use_these = datasample(use_these,N);


[~,sidx]=sort(nanmax(alldata.PD_PD(use_these,:),[],2) + nanmax(alldata.LP_LP(use_these,:),[],2));
use_these = use_these(sidx);



set(ax,'XScale','log')

X = alldata.PD_PD(use_these,:);
Y = repmat((1:length(use_these))',1,1e3);
scatter(ax,X(:),Y(:),1,'MarkerFaceColor',PD_color,'Marker','.','MarkerEdgeAlpha',Alpha,'MarkerFaceAlpha',Alpha);


X = alldata.LP_LP(use_these,:);
X = X*Spacing;
scatter(ax,X(:),Y(:),1,'MarkerFaceColor',LP_color,'Marker','.','MarkerEdgeAlpha',Alpha,'MarkerFaceAlpha',Alpha,'MarkerEdgeColor',LP_color);


X = alldata.LP_PD(use_these,:);
X = X*Spacing*Spacing;
X(X<1e4) = NaN;
scatter(ax,X(:),Y(:),1,'MarkerFaceColor',delay_color,'Marker','.','MarkerEdgeAlpha',Alpha,'MarkerFaceAlpha',Alpha,'MarkerEdgeColor',delay_color);

ax.YLim = [-20 N];
ax.XLim = [1e-3 1e10];

title(ax,char(idx),'FontWeight','normal')
ax.YColor = 'w';


ph = plot(ax,[1.1 1e12],[ax(1).YLim(1) ax(1).YLim(1)],'LineWidth',10,'Color','w');
ax.XTick = [1e-3 1];
ax.XMinorTick = 'on';


plot(ax,[1e-3],[ ax.YLim(2)],'Color',colors(idx),'Marker','.','MarkerSize',70)