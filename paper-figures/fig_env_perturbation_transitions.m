

%%
% In this file we generate transition matrices under
% different environmental perturbations

close all
init

figure('outerposition',[300 300 1777 1201],'PaperUnits','points','PaperSize',[1777 1201]); hold on
for i = 1:12
	ax(i) = subplot(3,4,i); hold on;
end
figlib.pretty('FontSize',20)

cats = categories(alldata.idx);

conditions = {alldata.temperature >= 25 & (alldata.decentralized == false),alldata.pH > 9.5, alldata.pH < 6.5, alldata.Potassium > 1};
condition_names = ["T > 25C", "pH > 9.5", "pH < 6.5", "2.5\times[K^+]"];

for i = 1:length(conditions)
	subplot(3,4,i); hold on
	only_when = conditions{i};
	J = analysis.computeTransitionMatrix(alldata.idx(only_when),alldata.time_offset(only_when));
	if i == length(conditions)
		lh = display.plotTransitionMatrix(J,cats,'ScaleFcn',@(x) 20*x + 7,'MarkerSize',15,'ShowScale',true);
	else
		display.plotTransitionMatrix(J,cats,'ScaleFcn',@(x) 20*x + 7,'MarkerSize',15);
	end
	title(condition_names(i),'FontSize',24,'FontWeight','normal')
end



things_to_measure = {'PD_burst_period','LP_burst_period'};
t_before = 10;
T = (0:-1:-t_before+1)*20;
 


for i = 1:length(conditions)
	only_when = conditions{i};

	[CV, CV0] = analysis.measureRegularCVBeforeTransitions(alldata,allmetrics,only_when,'things_to_measure',things_to_measure,'t_before',t_before);

	plot_here = struct;
	plot_here.PD_burst_period = subplot(3,4,4+i); hold on
	set(gca,'YLim',[0 .15])
	plot_here.LP_burst_period = subplot(3,4,8+i); hold on
	set(gca,'YLim',[0 .15])

	th = display.plotVariabilityBeforeTransition(CV,CV0,plot_here,T);
end

for i = 5:12
	ax(i).Position(4) = .2;
end
for i = 5:8
	ax(i).Position(2) = .38;
end
for i = 1:4
	ax(i).Position(4) = .3;
	ax(i).Position(2) = .65;
end

for i = 1:4
	ax(i).Units = 'pixels';
	ax(i).Position(4) = 300;
	ax(i).Position(3) = (ax(i).XLim(2)/ax(i).YLim(2))*ax(i).Position(4);
end

h = xlabel(ax(12),'Time before transition (s)');
h.Position = [-550 -.03];

h = ylabel(ax(9),'CV(T)');
h.Position = [-260 .17];

for i = 1:4
	ax(i).Units = 'normalized';
end

h = axlib.label(ax(1),'a','FontSize',28,'XOffset',-.03,'YOffset',-.01);
h = axlib.label(ax(5),'b','FontSize',28,'XOffset',-.03,'YOffset',-.01);

figlib.saveall('Location',display.saveHere)

display.trimImage([mfilename '_1.png']);

% clean up workspace
init()