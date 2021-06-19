% makes a legend identifying states so we can 
% use this is as a key

function lh = stateLegend(ax,cats, options)

arguments
	ax (1,1) matlab.graphics.axis.Axes
	cats (:,1) categorical
	options.NumColumns (1,1) double = 2
	options.Marker = '.'
	options.MarkerSize = 64
end

colors = display.colorscheme(cats);

cats = categories(cats);

hold(ax,'on')
clear lh
for i = length(cats):-1:1
	lh(i) = plot(ax,NaN,NaN,options.Marker,'MarkerSize',options.MarkerSize,'MarkerFaceColor',colors(cats{i}),'MarkerEdgeColor',colors(cats{i}));
end




lh = legend(lh,cats,'NumColumns',options.NumColumns);
lh.Position = ax.Position;
axis(ax,'off')

lh.FontSize = 14;
