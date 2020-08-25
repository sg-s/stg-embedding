% plots a CDF of some vector and boostraps to get a 
% error estimate 

function [lines, shade] = plotCDFWithError(X, Color)


arguments
	X (:,1) {mustBeNumeric}
	Color (3,1) double
end


X = X(:);
X(isnan(X)) = [];
[hy,hx] = histcounts(X,'Normalization','cdf','NumBins',100);
% bootstrap
E = zeros(100,100);
for i = 1:100
	E(:,i) = histcounts(datasample(X,length(X)),'Normalization','cdf','BinEdges',hx);
end
hx = hx(1:end-1) + mean(diff(hx))/2;
[lines,shade] = plotlib.errorShade(hx,hy,std(E,[],2),'Color',Color);
delete(lines(2:3))
lines = lines(1);
lines.LineWidth = 1.5;
set(gca,'YLim',[0 1])
ylabel('CDF')

ax = gca;
ax.XLim(1) = 0;