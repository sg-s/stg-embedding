% makes a figure coloring dots by experimenter

close all
init()


subidx = embedding.watersegment(R);
cats = categories(alldata.idx);
colors = display.colorscheme(alldata.idx);
is_baseline = ismember(hashes.alldata,hashes.basedata);

all_experimenters = categorical({'cronin','tang','haddad','powell'});

figure('outerposition',[300 300 1800 901],'PaperUnits','points','PaperSize',[1800 901]); hold on
clear ax

for i = 1:length(all_experimenters)
	ax(i) = subplot(2,2,i); hold on
	display.plotSubClusters(ax(i),alldata.idx,R,.1,subidx);
	axis(ax(i),'off')
	axis square

	plot_this = alldata.experimenter == all_experimenters(i) & is_baseline;



	for j = 1:length(cats)
		plot(R(alldata.idx == cats(j) & plot_this,1),R(alldata.idx == cats(j) & plot_this,2),'.','Color',colors(cats{j}),'MarkerSize',5)
	end

end








return



% % this init clears polluting variables
init()