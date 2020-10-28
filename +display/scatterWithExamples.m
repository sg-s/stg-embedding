% this function makes a scatter plot with marginal distributions
% and also shows some example points

function scatterWithExamples(data, examples, X, Y)


arguments
	data (1,1)  embedding.DataStore
	examples (:,1) double
	X (:,1) double
	Y (:,1) double
end


colors = display.colorscheme(data.idx);

sh = plotlib.scatterhist(X,Y,'Color','k');

for i = 1:length(examples)
	x = X(examples(i));
	y = Y(examples(i));
	if isnan(x) 
		x =  get(gca,'XLim');
		x = x(1);
	end
	if isnan(y) 
		y =  get(gca,'YLim');
		y = y(1);
	end
	C = colors.(data.idx(examples(i)));
	plot(x,y,'.','MarkerSize',25,'Color',C)
end