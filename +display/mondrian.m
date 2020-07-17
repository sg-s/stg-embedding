function p = mondrian(states, colors, cats);

if iscategorical(states)
	h = histcounts(states);
	cats = categories(states);
else
	% assume the probabilities have been calculated already
	h = states;
end

h = treemap.treemap(h);
p = treemap.plotRectangles(h);
for i = 1:length(p)
    p(i).FaceColor = colors(cats{i});
    p(i).EdgeColor = [1 1 1];
end

set(gca,'XLim',[0 1],'YLim',[0 1])
axis off