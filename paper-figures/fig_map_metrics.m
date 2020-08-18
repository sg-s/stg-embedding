% colors map by different metrics

close all




PDf = sum(~isnan(alldata.PD),2)/20;

C = [burst_metrics.PD_burst_period burst_metrics.LP_burst_period  burst_metrics.PD_duty_cycle burst_metrics.LP_duty_cycle burst_metrics.LP_phase_on PDf];
Limits = [0 2; 0 2; 0 1; 0 1; 0 1; 0 20];
Labels = {'T_{PD} (s)','T_{LP} (s)','Duty cycle_{PD}','Duty cycle_{LP}','LP phase','<f_{PD}> (Hz)'};


figure('outerposition',[300 100 1901 1201],'PaperUnits','points','PaperSize',[1901 1201]); hold on
clear ax
for i = 1:6
	ax(i) = subplot(2,3,i); hold on
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