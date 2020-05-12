



if ~exist('alldata','var')
    init()
end



modnames = {'proctolin','CabTrp1a','RPCH','oxotremorine','serotonin','CabTrp1a'};





close all
figure('outerposition',[300 300 1400 1111],'PaperUnits','points','PaperSize',[1400 1111]); hold on


for i = 1:length(modnames)
	ax(i) = subplot(2,3,i); hold on
	display.makeStackedHistogram(ax,alldata, modnames{i})
	title(modnames{i})
end




clearvars -except data alldata p