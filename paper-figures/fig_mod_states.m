
close all

init()


figure('outerposition',[300 300 1500 901],'PaperUnits','points','PaperSize',[1500 901]); hold on

clear ax

modnames = {'RPCH','proctolin','oxotremorine','serotonin'};

for i = 1:length(modnames)
	ax(i) = subplot(2,2,i); hold on


	% find all preps where this mod is used
	preps = unique(moddata.experiment_idx(moddata.(modnames{i}) > 0));
	preps = moddata.slice(ismember(moddata.experiment_idx,preps) & moddata.decentralized);


	display.pairedMondrian(ax(i),preps, preps.(modnames{i}) == 0, preps.(modnames{i}) > 0, 'decentralized', ['+' modnames{i}]);


end

figlib.pretty('FontSize',16)

figlib.saveall('Location',display.saveHere)


init()