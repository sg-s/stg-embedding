%%
% In this document I look at how transitions are affected by
% environmental perturbations


close all
init()

colors = display.colorscheme(alldata.idx);

conditions = {alldata.temperature >= 25 & (alldata.decentralized == false), alldata.pH < 6.5, alldata.Potassium > 1};

things_to_measure = {'PD_burst_period','LP_burst_period'};
t_before = 10;
T = (0:-1:-t_before+1)*20;

figure('outerposition',[300 300 1444 1100],'PaperUnits','points','PaperSize',[1444 1100]); hold on
n = 1;
for i = 1:length(things_to_measure)
	for j = 1:length(conditions)
		ax(j,i) = subplot(length(things_to_measure),length(conditions),n); hold on
		set(gca,'YLim',[0 .15])
		n = n+1;
		set(gca,'XTick',-200:40:0)
	end
end

figlib.pretty

title(ax(1,1),['T > 25' char(176)  'C'])
title(ax(2,1),'pH < 6.5')
title(ax(3,1),'2.5x [K^+]')

ylabel(ax(1,1),'CV (PD burst period)')
ylabel(ax(1,2),'CV (LP burst period)')

xlabel(ax(1,2),'Time before transition (s)')
xlabel(ax(2,2),'Time before transition (s)')
xlabel(ax(3,2),'Time before transition (s)')



for i = 1:length(conditions)
	only_when = conditions{i};

	[CV, CV0] = analysis.measureRegularCVBeforeOrAfterTransitions(alldata,allmetrics,only_when,'things_to_measure',things_to_measure,'T',t_before);

	plot_here = struct;
	for j = 1:length(things_to_measure)
		thing = things_to_measure{j};
		plot_here.(thing) = ax(i,j);
	end
	display.plotVariabilityBeforeTransition(CV,CV0,plot_here,T);
end



