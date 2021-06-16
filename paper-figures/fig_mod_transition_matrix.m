%%
% In this file we generate transition matrices under
% different environmental perturbations

close all
init

figure('outerposition',[300 300 1350 1555],'PaperUnits','points','PaperSize',[1350 1555]); hold on
figlib.pretty
cats = categories(moddata.idx);



modulators = ["RPCH","proctolin","oxotremorine","serotonin"];


% signficance level
Alpha = .05;

for i = 1:length(modulators)
	ax(i) = subplot(2,2,i); hold on
	only_when = moddata.(modulators(i)) >=5e-7;

	idx = moddata.idx(only_when);
	time = moddata.time_offset(only_when);
	exp_idx = moddata.experiment_idx(only_when);

	[J,~,~,J0] = analysis.computeTransitionMatrix(idx,time);

	disp(['N=' mat2str(length(unique(moddata.experiment_idx(only_when))))])


	ShowScale = i < length(modulators);



	% now bootstrap the J
	foo = @analysis.computeTransitionMatrix;
	JB = analysis.boostrapExperiments(foo,{idx,time},exp_idx,1e3);

	frac_below = mean(JB >= J0,3) < Alpha;
	frac_above = mean(JB <= J0,3) < Alpha;
	

	display.plotTransitionMatrix(J,cats,frac_below, frac_above, 'ShowScale',ShowScale);
	axis off
	th = title(modulators(i),'FontSize',24,'FontWeight','normal');
	 th.Position(1) = 6.5;
	set(gca,'XLim',[0 14.5],'YLim',[0 12.5])

end

for i = 1:4
	ax(i).Position(4) = .3;
end
for i = 1:2
	ax(i).Position(2) = .5;
end

lax = axes;
lax.Position = [.1 .85 .8 .12];
lax = display.stateLegend(lax,cats,4);
lax.FontSize = 16;
lax.Box = 'off';


figlib.saveall('Location',display.saveHere)

display.trimImage([mfilename '_1.png']);

% clean up workspace
init()
