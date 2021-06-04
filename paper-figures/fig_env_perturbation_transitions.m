

%%
% In this file we generate transition matrices under
% different environmental perturbations

close all
init

figure('outerposition',[300 300 1200 1201],'PaperUnits','points','PaperSize',[1200 1201]); hold on
figlib.pretty
cats = categories(alldata.idx);

conditions = {alldata.temperature >= 25 & (alldata.decentralized == false), alldata.pH < 6.5, alldata.Potassium > 1};
condition_names = ["T > 25C", "pH < 6.5", "2.5\times[K^+]"];

for i = 1:length(conditions)
	subplot(2,2,i); hold on
	only_when = conditions{i};
	J = analysis.computeTransitionMatrix(alldata.idx(only_when),alldata.time_offset(only_when));
	display.plotTransitionMatrix(J,cats);
	axis off
	axis square
	title(condition_names(i),'FontSize',24,'FontWeight','normal')
	set(gca,'XLim',[0 12.5],'YLim',[0 12.5])
end

ax = subplot(2,2,4); hold on
display.stateLegend(ax,cats);