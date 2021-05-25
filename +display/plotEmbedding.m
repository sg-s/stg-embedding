function plotEmbedding(ax, R, idx)


arguments
	ax (1,1) matlab.graphics.axis.Axes
	R (:,2) double
	idx (:,1) categorical
end

cats = categories(idx);

colors = display.colorscheme(cats);

plot(ax,R(:,1),R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)
for i = length(cats):-1:1
    plot(ax,R(idx==cats{i},1),R(idx==cats{i},2),'.','Color',colors(cats{i}),'MarkerSize',10)
    
end
axis(ax,'square')
