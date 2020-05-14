% makes a figure showing the map, with pts coloured by dwell time 

clearvars -except data alldata p

R = double(alldata.R);

cats = categories(alldata.idx);
colors = display.colorscheme(cats);



figure('outerposition',[300 108 1301 1301],'PaperUnits','points','PaperSize',[1301 1301]); hold on

axis off
axis square

figlib.pretty('LineWidth',1)

sub_idx = embedding.watersegment(alldata);


% find dwelltimes by subcluster
dwell_times = NaN*(1:max(sub_idx));
for i = 1:max(sub_idx)
	[ons,offs]=veclib.computeOnsOffs(sub_idx==i);
	dwell_times(i) = median(((offs - ons) + 1)*20);
end


fh = display.plotSubClusters(gca,alldata,.1,sub_idx);

FontSize = @(x) 14+ 20*(x - min(dwell_times))/(max(dwell_times) - min(dwell_times))

for i = 1:max(sub_idx)
	mx = mean(R(sub_idx==i,1));
	my = mean(R(sub_idx==i,2));
	text(mx,my,mat2str(dwell_times(i),4),'FontSize',FontSize(dwell_times(i)),'HorizontalAlignment','center')
end





clearvars -except data alldata p