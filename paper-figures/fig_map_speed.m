% speed of points in t-SNE space
% speed is the same as distance between subsequent points 
% so it is sufficient to find the distance between subsequent points
% and carefully censor when we switch preps


close all

D = analysis.distanceBetweenSubsequentPts(alldata,R);
D2 = analysis.distanceBetweenSubsequentPts(alldata,R,-1);
D = min(D,D2);

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(1,2,1); hold on
x = logspace(-3,2,100);
histogram(D,x)
set(gca,'XScale','log')

subplot(1,2,2); hold on
plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8])

idx = embedding.watersegment(R);

D_segements = D*NaN;
for i = 1:max(idx)
	this = idx == i;
	D_segments(this) = nanmean(D(this));
end

D_segments = log(D_segments);
this = ~isnan(D_segments) | isinf(D_segments);
scatter(R(this,1),R(this,2),6,(D_segments(this)))

