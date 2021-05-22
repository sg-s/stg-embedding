function th = scatterWithCorrelation(X,Y, options)

arguments
	X (:,1) double
	Y (:,1) double
	options.MarkerSize = 10
	options.Color = [.5 .5 .5]
end


rm_this = isnan(X) | isnan(Y);
X(rm_this) = [];
Y(rm_this) = [];


assert(length(X)==length(Y),'Lengths dont match')


plot(X,Y,'.','MarkerSize',options.MarkerSize,'Color',options.Color)
[rho,p]=corr(X,Y,'Type','Spearman');
th = text(10,.3,['\rho=' mat2str(rho,2) ', \itp=' mat2str(p,2)]);

th.Position(1) = prctile(X,20);
th.Position(2) = max(Y)*1.1;

set(gca,'YLim',[min(Y) max(Y)*1.2]);
