% makes a legend identifying states so we can 
% use this is as a key

function lh = stateLegend(ax,cats, NumColumns)

arguments
	ax (1,1) matlab.graphics.axis.Axes
	cats (:,1) categorical
	NumColumns (1,1) double = 2
end

colors = display.colorscheme(cats);

cats = categories(cats);

hold(ax,'on')
clear lh
for i = length(cats):-1:1
	lh(i) = plot(ax,NaN,NaN,'.','MarkerSize',64,'Color',colors(cats{i}));
end




lh = legend(lh,cats,'NumColumns',NumColumns);
lh.Position = ax.Position;
axis(ax,'off')

lh.FontSize = 14;
