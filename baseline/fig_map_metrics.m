% colors map by different metrics

close all
clearvars -except data alldata metricsPD metricsLP


% get data
if ~exist('metricsPD','var')


	% compute sub-dominant period
	DataSize = length(alldata.mask);
	for i = 1:DataSize
		offset = nanmin([nanmin(alldata.PD(i,:)) nanmin(alldata.LP(i,:))]);
		alldata.PD(i,:) = alldata.PD(i,:) - offset;
		alldata.LP(i,:) = alldata.LP(i,:) - offset;
	end

	metricsPD = sourcedata.ISI2DominantPeriod(alldata.PD,alldata.PD_PD);
	metricsLP = sourcedata.ISI2DominantPeriod(alldata.LP,alldata.LP_LP);

	metricsPD.DominantPeriod(metricsPD.DominantPeriod==20) = NaN;
	metricsLP.DominantPeriod(metricsLP.DominantPeriod==20) = NaN;

end



C = [metricsLP.DominantPeriod metricsLP.ACF_values abs(metricsPD.DominantPeriod - metricsLP.DominantPeriod) sum(~isnan(alldata.LP),2)/20];
Limits = [0 2; 0 1; 0 2; 0 20];
Labels = {'T_{LP} (s)','Peak ACF','T_{PD}-T_{LP} (s)','<f_{LP}> (Hz)'};


figure('outerposition',[300 300 1302 1201],'PaperUnits','points','PaperSize',[1302 1201]); hold on
clear ax
for i = 1:4
	ax(i) = subplot(2,2,i); hold on
	plot(alldata.R(:,1),alldata.R(:,2),'.','Color',[.8 .8 .8],'MarkerSize',24)
	scatter(alldata.R(:,1),alldata.R(:,2),6,C(:,i),'filled')
	axis square
	caxis(Limits(i,:))
	axis off


end


figlib.pretty

insets = figlib.inset(ax);
for i = 1:4

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



for i = 1:length(ax)
    ax(i).Position(3:4) = .37;
end

