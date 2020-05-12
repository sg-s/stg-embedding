
close all

if ~exist('alldata','var')
    init()
end

m = sourcedata.modulatorUsed(data);

figure('outerposition',[300 300 1500 901],'PaperUnits','points','PaperSize',[1500 901]); hold on

clear ax

modnames = {'RPCH','proctolin','oxotremorine','serotonin'};

for i = 1:length(modnames)
	ax(i) = subplot(2,2,i); hold on
	display.pairedMondrian(ax(i),alldata, modnames{i})
end

figlib.pretty()




clearvars -except data alldata p