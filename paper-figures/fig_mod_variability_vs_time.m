%%
% In this document I look at how transitions are affected by
% environmental perturbations


close all
init()

colors = display.colorscheme(alldata.idx);
cats = categories(alldata.idx);

things_to_measure = {'PD_burst_period','LP_burst_period'};
t_before = 10;


figure('outerposition',[300 300 1444 800],'PaperUnits','points','PaperSize',[1444 800]); hold on
for i = 1:length(things_to_measure)
	thing = things_to_measure{i};
	ax.(thing) = subplot(1,2,i); hold on
	ax.(thing).YLim = [0 .12];
end



T = (0:-1:-t_before+1)*20;
%T = (0:1:t_before-1)*20;

only_when = alldata.serotonin >= 5e-7 & alldata.decentralized;

[CV, CV0] = analysis.measureRegularCVBeforeOrAfterTransitions(alldata,allmetrics,only_when,'things_to_measure',things_to_measure,'T',t_before,'BeforeOrAfter','Before');




th = display.plotVariabilityBeforeTransition(CV,CV0,ax,T);
th(1).Position(1) = 0;
th(2).Position(1) = 0;





