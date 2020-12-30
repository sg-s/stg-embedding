% speed of points in t-SNE space
% speed is the same as distance between subsequent points 
% so it is sufficient to find the distance between subsequent points
% and carefully censor when we switch preps


close all
init()

D1 = analysis.distanceBetweenSubsequentPts(alldata,R);
D2 = analysis.distanceBetweenSubsequentPts(alldata,R,-1);


% show each state with correct color
colors = display.colorscheme(alldata.idx);
unique_cats = unique(alldata.idx);


D = log(min(D1,D2));
idx = alldata.idx;

all_preps = unique(alldata.experiment_idx);
DD = NaN(length(all_preps),length(unique_cats));

for i = 1:length(unique_cats)
	for j = 1:length(all_preps)
		this = alldata.experiment_idx == all_preps(j) & alldata.idx == unique_cats(i);
		DD(j,i) = nanmean(D(this));
	end
end
idx = repmat(unique_cats,1,size(DD,1))';
idx = idx(:);
DD = DD(:);

rm_this = isnan(DD) | isinf(DD);
DD(rm_this) = [];
idx(rm_this) = [];

% anova1(DD(~rm_this),idx(~rm_this))

% simple permuatation test between normal and everything else
p = NaN(length(unique_cats),1);
for i = 1:length(unique_cats)
	[p(i),obs_dif,eff_size]=statlib.permutationTest(DD(idx=='normal'),DD(idx==unique_cats(i)),1e4);
end


D = log(min(D1,D2));


figure('outerposition',[300 300 1555 901],'PaperUnits','points','PaperSize',[1555 901]); hold on
clear ax
ax(2) = subplot(1,2,2); hold on


% plot speed distribution grouped by state



% [~,idx]=sort(analysis.averageBy(D,alldata.idx));
% unique_cats = unique_cats(idx);

for i = 1:length(unique_cats)
	this = D(alldata.idx==unique_cats(i));
	this(isinf(this)) = [];
	this(isnan(this)) = [];
	plotlib.raincloud(this,'YOffset',i*2,'Color',colors(unique_cats(i)));
end

set(gca,'YTick',2:2:2*i,'YTickLabels',corelib.categorical2cell(unique_cats))
xlabel('log speed (a.u.)')




ax(1) = subplot(1,2,1); hold on
plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8])
axis off
axis square

scatter(R(:,1),R(:,2),3,D,'filled')

caxis([-3 1])

ch = colorbar;
ch.Location = 'southoutside';
title(ch,'log speed (a.u.)')


ax(2).YLim = [1 25];
ax(1).Position = [.07 .11 .38 .8];


figlib.pretty()





ch.Position = [.07 .08 .2 .01];

figlib.label('FontSize',32,'XOffset',-.01)


figlib.saveall('Location',display.saveHere)
init()