%%
% In this file we generate transition matrices under
% different environmental perturbations

close all
init

figure('outerposition',[300 300 1200 1201],'PaperUnits','points','PaperSize',[1200 1201]); hold on
figlib.pretty
cats = categories(moddata.idx);


modulators = ["RPCH","proctolin","oxotremorine","serotonin"];


for i = 1:length(modulators)
	subplot(2,2,i); hold on
	only_when = moddata.(modulators(i)) >=5e-7;
	J = analysis.computeTransitionMatrix(moddata.idx(only_when),moddata.time_offset(only_when));
	display.plotTransitionMatrix(J,cats);
	axis off
	axis square
	title(modulators(i),'FontSize',24,'FontWeight','normal')
	set(gca,'XLim',[0 12.5],'YLim',[0 12.5])
end

