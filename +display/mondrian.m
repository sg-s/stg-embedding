% makes a mondrian plot (a treemap)
% from a list of states 

function p = mondrian(states, cats)
	
if iscategorical(states)
	h = histcounts(states);
	cats = categories(states);
else
	% assume the probabilities have been calculated already
	h = states;
end

colors = display.colorscheme(cats);

h = treemap.treemap(h);
p = treemap.plotRectangles(h);
for i = 1:length(p)
    p(i).FaceColor = colors(cats{i});
    p(i).EdgeColor = [1 1 1];
end


padding = .03;
axis off
view([90 -90])
set(gca,'XLim',[0-padding 1+padding],'YLim',[0-padding 1+padding])