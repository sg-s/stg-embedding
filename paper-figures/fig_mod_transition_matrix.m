%%
% In this file we generate transition matrices under
% different environmental perturbations

close all
init

figure('outerposition',[300 300 1701 1201],'PaperUnits','points','PaperSize',[1701 1201]); hold on
ax(5) = subplot(4,3,8); hold on
ax(6) = subplot(4,3,11); hold on
figlib.pretty
cats = categories(moddata.idx);



modulators = ["RPCH","proctolin","oxotremorine","serotonin"];


% signficance level
Alpha = .05;

for i = 1:length(modulators)
	ax(i) = subplot(2,3,i); hold on
	only_when = moddata.(modulators(i)) >=5e-7;

	idx = moddata.idx(only_when);
	time = moddata.time_offset(only_when);
	exp_idx = moddata.experiment_idx(only_when);

	[J,J_raw,~,p_below, p_above] = analysis.computeTransitionMatrix(idx,time);

	disp(['N=' mat2str(length(unique(moddata.experiment_idx(only_when))))])


	ShowScale = i == 4;


	% now bootstrap the J
	% foo = @analysis.computeTransitionMatrix;
	% JB = analysis.boostrapExperiments(foo,{idx,time},exp_idx,1e3);



	% frac_below = mean(JB >= J0,3) < Alpha;
	% frac_above = mean(JB <= J0,3) < Alpha;
	

	display.plotTransitionMatrix(J,cats,p_below, p_above, 'ShowScale',ShowScale);
	axis off


end




% now show how variability changes over time in serotonin
% so we can compare it to similar plots for decentralized
% and environmental perturbations

t_before = 10;
T = (0:-1:-t_before+1)*20;

only_when = alldata.serotonin >= 5e-7 & alldata.decentralized;

things_to_measure = {'PD_burst_period','LP_burst_period'};	
[CV, CV0] = analysis.measureRegularCVBeforeOrAfterTransitions(alldata,allmetrics,only_when,'things_to_measure',things_to_measure,'T',t_before);
clear sax
sax.PD_burst_period = subplot(4,3,8); hold on
sax.PD_burst_period.YLim(2) = .125;
sax.LP_burst_period = subplot(4,3,11); hold on
sax.LP_burst_period.YLim(2) = .125;

th = display.plotVariabilityBeforeTransition(CV,CV0,sax,T);
ylabel(sax.PD_burst_period,'CV (T_{PD})')
ylabel(sax.LP_burst_period,'CV (T_{LP})')
xlabel(sax.LP_burst_period,'Time before transition (s)');


lax = subplot(2,3,6);

lax = display.stateLegend(lax,cats,'Marker','>');
lax.FontSize = 16;
lax.Box = 'off';

for i = 1:4
	ax(i).Position(3:4) = [.3 .45];
	ax(i).Position(2) = ax(i).Position(2) - .075;
	th = title(ax(i),modulators(i),'FontSize',24,'FontWeight','normal');
	th.Position(1) = 6.5;
	th.Position(2) = 12.5;
end


ax(5).Position(2) = .3;
ax(5).Position(1) = .5;
ax(6).Position(1) = .5;

lax.Position = [.75 .1 .2 .35];

figlib.saveall('Location',display.saveHere)

display.trimImage([mfilename '_1.png']);

% clean up workspace
init()
