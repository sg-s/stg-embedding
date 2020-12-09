% speed of points in t-SNE space
% speed is the same as distance between subsequent points 
% so it is sufficient to find the distance between subsequent points
% and carefully censor when we switch preps


close all

D = analysis.distanceBetweenSubsequentPts(alldata,R);
D2 = analysis.distanceBetweenSubsequentPts(alldata,R,-1);
D = log(min(D,D2));

figure('outerposition',[300 300 1555 901],'PaperUnits','points','PaperSize',[1555 901]); hold on
clear ax
ax(2) = subplot(2,2,4); hold on
x = linspace(-10,5,101);
y = histcounts(D,x);
y = y/sum(y);
h = area(x(2:end) + diff(x),y);
xlabel('log Speed (a.u.)')
ylabel('Probability')
h.FaceAlpha = .5;


subplot(1,2,1); hold on
plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8])
axis off
axis square

idx = embedding.watersegment(R);

D_segements = D*NaN;
for i = 1:max(idx)
	this = idx == i;
	D_segments(this) = nanmean(D(this));
end

this = ~isnan(D_segments) | isinf(D_segments);
scatter(R(this,1),R(this,2),6,(D_segments(this)),'filled')

caxis([-3 1])

[N,u]=histcounts(alldata.experiment_idx);
[~,idx] = sort(N,'descend');
u = u(idx);

subplot(2,2,2); hold on
y = R(alldata.experiment_idx == u{3},1);
x = (1:length(y))*20/60;
plot(x,y,'r')
set(gca,'XLim',[0 100],'YLim',[-5 20])
xlabel('Time (min)')
ylabel('X-position in map (a.u.)')

figlib.pretty()
