% colors map by different metrics

close all


% get the embedding
if ~exist('R','var')
    [p,NormalizedMetrics, VectorizedData] = alldata.vectorizeSpikes2;

    fitData = VectorizedData;

    % original
    u = umap('min_dist',1, 'metric','euclidean','n_neighbors',75,'negative_sample_rate',25);
    u.labels = alldata.idx;
    R = u.fit(fitData);
end

if ~exist('metricsPD','var')

	metricsLP = alldata.ISIAutocorrelationPeriod('LP');
	metricsPD = alldata.ISIAutocorrelationPeriod('PD');

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
	plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerSize',24)
	scatter(R(:,1),R(:,2),6,C(:,i),'filled')
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
    ax(i).XLim = [-30 40];
    ax(i).YLim = [-30 40];
end

clearvars -except data alldata metricsPD metricsLP R