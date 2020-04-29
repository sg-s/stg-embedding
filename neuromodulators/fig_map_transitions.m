% makes a figure showing the map, and colors points by condition
% the state is indicated by a shading in the background,
% and sub-clusters are found using watershed

clearvars -except data alldata p

R = double(alldata.R);
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

sub_idx = embedding.watersegment(alldata);


conditions = {'baseline','decentralized','CabTrp1a','RPCH','proctolin','oxotremorine'};


for ci = 1:length(conditions)
	fh = display.plotSubClusters(ax(ci),alldata,.1,sub_idx);
	plot_this = filterData(alldata,conditions{ci});

	J = embedding.computeTransitionMatrix(categorical(sub_idx));
	J(J<prctile(J(:),95)) = 0;
	G = digraph(J);
	ph = plot(G);

	ph.Parent = ax(ci);

	for i = 1:max(sub_idx)
		ph.XData(i) = mean(R(sub_idx==i,1));
		ph.YData(i) = mean(R(sub_idx==i,2));
	end


	% for i = 1:length(cats)
	% 	plot(ax(ci),R(alldata.idx == cats(i) & plot_this,1),R(alldata.idx == cats(i) & plot_this,2),'.','Color',colors(cats{i}),'MarkerSize',10)
	% end

	title(ax(ci),conditions{ci},'FontWeight','normal')

	
end

axlib.move(ax(4:6),'down',.02)



return
clearvars -except data alldata p