% makes a figure showing the map, and colors points by condition
% the state is indicated by a shading in the background,
% and sub-clusters are found using watershed

init()



cats = categories(alldata.idx);
colors = display.colorscheme(cats);

figure('outerposition',[300 108 1900 1301],'PaperUnits','points','PaperSize',[1900 1301]); hold on
clf;
ax = axlib.tight_subplot(2,3);

for i = 1:6
	ax(i).XLim = [min(R(:)) max(R(:))];
	ax(i).YLim = [min(R(:)) max(R(:))];
	axis(ax(i),'on')
	box(ax(i),'on')
	ax(i).XTick = [];
	ax(i).YTick = [];
	hold(ax(i),'on')
end


figlib.pretty('LineWidth',1)




modulators = {'serotonin','CabTrp1a','RPCH','proctolin','oxotremorine','CCAP'};


for ci = 1:length(modulators)


	% plot all points as a background
	plot(ax(ci),R(:,1),R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)

	% find all pts where the modulator is used
	plot_this = hashes.moddata(moddata.(modulators{ci})>0);
	plot_this = ismember(hashes.alldata,plot_this);


	for i = 1:length(cats)
		plot(ax(ci),R(alldata.idx == cats(i) & plot_this,1),R(alldata.idx == cats(i) & plot_this,2),'.','Color',colors(cats{i}),'MarkerSize',20)
	end

	title(ax(ci),modulators{ci},'FontWeight','normal')

	
end

axlib.move(ax(4:6),'down',.02)


return


init()