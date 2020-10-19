% colors map by different metrics

close all
init()



PDf = sum(~isnan(alldata.PD),2)/20;

C = [allmetrics.PD_burst_period allmetrics.LP_phase_on PDf];
Limits = [0 2; 0 1; 0 20];
Labels = {'T_{PD} (s)','LP phase','<f_{PD}> (Hz)'};


figure('outerposition',[300 100 1901 801],'PaperUnits','points','PaperSize',[1901 801]); hold on
clear ax
for i = 1:3
	ax(i) = subplot(1,3,i); hold on
	plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerSize',24)
	scatter(R(:,1),R(:,2),6,C(:,i),'filled')
	axis square
	caxis(Limits(i,:))
	axis off


end


figlib.pretty

insets = figlib.inset(ax);
for i = 1:length(ax)

	p(i) = plotlib.colorhist(insets(i),C(:,i),'BinLimits',Limits(i,:));

	insets(i).Box = 'off';
	insets(i).YScale = 'log';
	insets(i).YColor = 'w';

	insets(i).Position(4) = .05;
	insets(i).Position(2) = insets(i).Position(2) + .1;
	insets(i).FontSize = 16;
	insets(i).XLim = Limits(i,:);
	xlabel(insets(i),Labels{i})
end


axlib.move(ax,'left',.03)


figlib.saveall('Location',display.saveHere)

init()