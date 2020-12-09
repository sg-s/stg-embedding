function plotBackgroundLabels(ax,alldata, R)

arguments
	ax (1,1) matlab.graphics.axis.Axes
	alldata (1,1) embedding.DataStore
	R (:,2)
end



cats = categories(alldata.idx);
colors = display.colorscheme(cats);
unique_cats = unique(alldata.idx);

for i = length(unique_cats):-1:1

	this_cat = unique_cats(i);
	this = alldata.idx == this_cat;

	X = R(this,:);
	X = datasample(X,length(X)*10);

	X = X + randn(length(X),2)/5;

	ph = plot(ax,X(:,1),X(:,2),'.','MarkerSize',20,'MarkerFaceColor',colors.(this_cat));
	ph.Color = colors.(this_cat);


end

r = patch(ax,[-35 35 35 -35],[-35 -35 35 35],'w');
r.FaceAlpha = .8;
r.EdgeColor = 'w';