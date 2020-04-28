% makes a figure showing the map, and colors points by condition
% the state is indicated by a shading in the background,
% and sub-clusters are found using watershed

clearvars -except data alldata p

R = double(alldata.R);
cats = categories(alldata.idx);
colors = display.colorscheme(cats);

figure('outerposition',[300 300 1200 801],'PaperUnits','points','PaperSize',[1200 801]); hold on
figlib.pretty()

sub_idx = embedding.watersegment(alldata);


conditions = {'baseline','decentralized','CabTrp1a','RPCH','proctolin','oxotremorine'};


for ci = 1:length(conditions)
	ax(ci) = subplot(2,3,ci); hold on
	fh = display.plotSubClusters(gca,alldata,.1,sub_idx);
	plot_this = filterData(alldata,conditions{ci});
	for i = 1:length(cats)
		plot(R(alldata.idx == cats(i) & plot_this,1),R(alldata.idx == cats(i) & plot_this,2),'.','Color',colors(cats{i}),'MarkerSize',10)
	end
	axis off
	axis square
	title(conditions{ci})
end

return
clearvars -except data alldata p