% plots a CDF of some vector and boostraps to get a 
% error estimate 

function [lines, shade] = plotCDFWithError(X, Color, NumBins, N)


arguments
	X (:,1) {mustBeNumeric}
	Color (3,1) double = [0 0 0];
	NumBins (1,1) double = 100;
	N (1,1) double = 100;
end


X = X(:);
X(isnan(X)) = [];
X(isinf(X)) = [];
[hy,hx] = histcounts(X,'Normalization','cdf','NumBins',NumBins);
% bootstrap
E = zeros(NumBins,N);
for i = 1:N
	E(:,i) = histcounts(datasample(X,length(X)),'Normalization','cdf','BinEdges',hx);
end
hx = hx(1:end-1) + mean(diff(hx))/2;


[lines,shade] = plotlib.errorShade(hx,hy,std(E,[],2),'Color',Color);
try
	delete(lines(2:3))
catch
end
lines = lines(1);
lines.LineWidth = 1.5;
set(gca,'YLim',[0 1])
ylabel('CDF')

ax = gca;
ax.XLim(1) = 0;