

%%
% In this file we generate transition matrices under
% different environmental perturbations

close all
init

figure('outerposition',[300 300 1777 1303],'PaperUnits','points','PaperSize',[1777 1303]); hold on
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

	idx = alldata.idx(only_when);
	time = alldata.time_offset(only_when);
	exp_idx = alldata.experiment_idx(only_when);

	[J, ~, marginal_counts, p_below, p_above] = analysis.computeTransitionMatrix(idx,time);


	ShowScale = i == length(conditions);
	display.plotTransitionMatrix(J,cats,p_below, p_above,'ScaleFcn',@(x) 20*x + 7,'MarkerSize',15,'ShowScale',ShowScale);
	title(condition_names(i),'FontSize',24,'FontWeight','normal')
end

things_to_measure = {'PD_burst_period','LP_burst_period'};
t_before = 10;
T = (0:-1:-t_before+1)*20;
 


for i = 1:length(conditions)
	only_when = conditions{i};

	[CV, CV0] = analysis.measureRegularCVBeforeOrAfterTransitions(alldata,allmetrics,only_when,'things_to_measure',things_to_measure,'T',t_before);

	plot_here = struct;
	plot_here.PD_burst_period = subplot(3,4,4+i); hold on
	set(gca,'YLim',[0 .15])
	plot_here.LP_burst_period = subplot(3,4,8+i); hold on
	set(gca,'YLim',[0 .15])

	th = display.plotVariabilityBeforeTransition(CV,CV0,plot_here,T);
end

for i = 5:12
	ax(i).Position(4) = .2;
	ax(i).Position(2) = .07;
end
for i = 5:8
	ax(i).Position(2) = .34;
end
for i = 1:4
	ax(i).Position(4) = .3;
	ax(i).Position(2) = .55;
	ax(i).Position(3) = .2;
end


h = xlabel(ax(12),'Time before transition (s)');
h.Position = [-550 -.03];

ylabel(ax(9),'CV (T_{LP})');
ylabel(ax(5),'CV (T_{PD})');


axlib.label(ax(1),'a','FontSize',28,'XOffset',-.03,'YOffset',-.01);
axlib.label(ax(5),'b','FontSize',28,'XOffset',-.03,'YOffset',-.01);


% add a legend
lax = axes;
lax.Position = [.1 .9 .8 .09];
lax = display.stateLegend(lax, cats, 'NumColumns',6,'Marker','>');
lax.Box = 'off';
lax.FontSize = 20;

figlib.saveall('Location',display.saveHere)

display.trimImage([mfilename '_1.png']);

% clean up workspace
init()