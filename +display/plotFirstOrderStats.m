function ax = plotFirstOrderStats(idx,colors)

figure('outerposition',[300 300 801 901],'PaperUnits','points','PaperSize',[801 901]); hold on
clear ax
ax.Hist = subplot(2,2,1); hold on
ax.DwellTimes = subplot(2,1,2); hold on
ax.graph = subplot(2,2,2); hold on

cats = unique(idx);



all_x = [];
all_y = [];

for i = 1:length(cats)
	[ons,offs]=veclib.computeOnsOffs(idx == cats(i));
	dwell_times = (offs-ons)*20; 
	dwell_times(dwell_times==0) = 20;
	all_y = [all_y; log10(dwell_times)];
	all_x = [all_x; repmat(categorical(cats(i)),length(dwell_times),1)];

end


axes(ax.DwellTimes)
vs = violinplot(all_y,all_x);

for i = 1:length(vs)
	vs(i).ViolinColor = colors(cats(i));
end

ylabel(ax.DwellTimes,'Dwell Time (s)')
set(ax.DwellTimes,'YTick',1:4,'YTickLabel',{'10^1','10^2','10^3','10^4'},'YGrid','on')



% clean up cats
cats = unique(idx);
cats = corelib.categorical2cell(unique(idx));
all_cats = categories(idx);
remove_cats =  setdiff(all_cats,cats);
for i = 1:length(remove_cats)
    idx = removecats(idx,remove_cats{i});
end


J = embedding.computeTransitionMatrix(idx);

J2 = J; J2(J<prctile(J(:),80)) = 0; G = digraph(J2); 

axes(ax.graph)

p = plot(G,'Layout','layered'); 

G.Edges.LWidths = 7*G.Edges.Weight/max(G.Edges.Weight);
p.LineWidth = G.Edges.LWidths;

sz = histcounts(idx);
sz = sz/sum(sz);


for i = 1:length(cats)

	barh(ax.Hist,i,sz(i),'FaceColor',colors(cats{i}))
	
	plot(ax.graph,p.XData(i),p.YData(i),'o','MarkerFaceColor',colors(cats{i}),'MarkerEdgeColor',colors(cats{i}),'MarkerSize',10+sz(i)*40)
end

p.NodeLabel = {};
p.EdgeColor = [.5 .5 .5];
p.ArrowSize = 12;

ax.Hist.YTickLabel = cats;
ax.Hist.YTick = 1:length(cats);

axis(ax.graph,'off')


ax.DwellTimes.XLim(1) = 0;
ax.DwellTimes.YLim = [1 4];

ax.graph.XLim(1) = 0.5;
ax.graph.YLim(1) = 0.5;

ax.DwellTimes.XTickLabelRotation = 45;

xlabel(ax.Hist,'Fraction of time')

figlib.pretty('FontSize',15)

ax.Hist.Position = [.2 .56 .33 .33];