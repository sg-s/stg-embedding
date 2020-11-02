

init()

dwell_times = analysis.timeToStateChange(alldata.idx,alldata.time_offset);





% need to average in a grid
S = linspace(-30,30,100);
Spacing = (S(2)-S(1))/2;
[X,Y] = meshgrid(S,S);

X = X(:);
Y = Y(:);
Z = NaN*X;

for i = 1:length(X)
	z = dwell_times(abs(R(:,1) - X(i)) < Spacing & abs(R(:,2) - Y(i)) < Spacing);
	if isempty(z)
		continue
	end
	Z(i) = nanmean(z);
end


figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

ax1 = subplot(1,2,1); hold on

display.plotBackgroundLabels(gca,alldata, R)

sh = scatter(X,Y,50,log10(Z),'filled');
sh.Marker = 's';
colormap(flipud(gray))
ch = colorbar('Location','southoutside');
axis square
axis off


cats = categories(alldata.idx);
colors = display.colorscheme(alldata.idx);

ax2 = subplot(1,2,2); hold on

% sort them by dwell times
D = zeros(length(cats),1);
for i = 1:length(cats)
	D(i) = nanmean(dwell_times(alldata.idx==cats{i}));
end

[~,sort_idx] = sort(D);
cats = cats(sort_idx);

for i = 1:length(cats)
	[S,P] = plotlib.raincloud(log10(dwell_times(alldata.idx==cats{i})),'YOffset',i*2,'Color',colors.(cats{i}));
end




figlib.pretty()

ax2.YTick = 2:2:2*length(cats);
ax2.YLim = [0 2*length(cats)+2];
ax2.YTickLabel = cats;
ax1.Position = [.01 .1 .45 .8];
ch.Position = [.1 0.05 .3 .03];
ch.Ticks = [2  3];
ch.TickLabels = {'10^{2}','10^{3}'};
ax2.XLim = [1 4];
ax2.XTick = [1 2 3 4];
ax2.XTickLabel = {'10','10^{2}','10^{3}','10^{4}'};
xlabel(ax2,'Dwell time (s)')

% cleanup
figlib.saveall('Location',display.saveHere)


init()