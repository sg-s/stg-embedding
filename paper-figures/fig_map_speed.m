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
ax(2) = subplot(1,2,2); hold on


% plot speed distribution grouped by state

% show each state with correct color
colors = display.colorscheme(alldata.idx);
unique_cats = unique(alldata.idx);

[~,idx]=sort(analysis.averageBy(D,alldata.idx));
unique_cats = unique_cats(idx);

for i = 1:length(unique_cats)
	this = D(alldata.idx==unique_cats(i));
	this(isinf(this)) = [];
	this(isnan(this)) = [];
	plotlib.raincloud(this,'YOffset',i*2,'Color',colors(unique_cats(i)))
end

set(gca,'YTick',2:2:2*i,'YTickLabels',corelib.categorical2cell(unique_cats))
xlabel('log speed (a.u.)')




ax(1) = subplot(1,2,1); hold on
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

ch = colorbar;
ch.Location = 'southoutside';
title(ch,'log speed (a.u.)')


ax(2).YLim = [1 25];
ax(1).Position = [.07 .11 .38 .8];


figlib.pretty()


ch.Position = [.07 .08 .2 .01];


figlib.saveall('Location',display.saveHere)
init()