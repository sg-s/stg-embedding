
close all

init()


figure('outerposition',[300 300 1500 1111],'PaperUnits','points','PaperSize',[1500 1111]); hold on

clear ax

modnames = {'RPCH','proctolin','oxotremorine','serotonin'};


for i = length(modnames):-1:1
	ax(i) = subplot(2,2,i); hold on
	ax(i).Position(4) = .28;
	
	if i < 3
		ax(i).Position(2) = .52;
	end
	axlib.label(ax(i),char(96+i),'XOffset',-.04,'FontSize',24);
end

axl = axes;

axl.Position = [.05 .88 .9 .1];
cats = categories(alldata.idx);
L = display.stateLegend(axl,cats,6);


for i = 1:length(modnames)
	

	

	% find all preps where this mod is used
	preps = unique(moddata.experiment_idx(moddata.(modnames{i}) > 0));
	preps = moddata.slice(ismember(moddata.experiment_idx,preps) & moddata.decentralized);



	% only use the first half of the decentralized data 
	% without modulator because we want to make sure we 
	% don't want to accidentally include data where 
	% neuromod is added (but isn't labeled as such because we want to ignore transients)
	T = analysis.forEachPrep(preps,@analysis.falseForSecondHalfDecentralized);
	preps = preps.slice(T);



	display.pairedMondrian(ax(i),preps, preps.(modnames{i}) == 0, preps.(modnames{i}) >= 5e-7, 'decentralized', ['+' modnames{i}]);


end




figlib.pretty('FontSize',16)


return




% analysis of variability 
figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
clear ax


for i = 1:2
	ax(i) = subplot(1,2,i); hold on
	set(ax(i),'XTick',1:length(modnames),'XTickLabel',modnames,'XTickLabelRotation',45,'XLim',[0 5])
end
% compare prob. of regular prep by prep between mods

colors = display.colorscheme(alldata.idx);
cats = categories(alldata.idx);
N = 0;
for i = 1:length(modnames)

	preps = unique(moddata.experiment_idx(moddata.(modnames{i}) > 0));
	preps = moddata.slice(ismember(moddata.experiment_idx,preps) & moddata.decentralized);

	preps = preps.slice(preps.(modnames{i}) > 0);

	p = preps.probState;

	x = randn(size(p,1),1)*.1 + i;
	plot(ax(1),x,p(:,1),'o','MarkerFaceColor',colors.regular,'MarkerEdgeColor',colors.regular)

	for j = 1:size(p,2)
		y = nanstd(p(:,j))/nanmean(p(:,j));
		plot(ax(2),i + randn*.1, y,'o','MarkerFaceColor',colors(cats{j}),'MarkerEdgeColor',colors(cats{j}))
	end

	N = N + size(p,1);
end
ylabel(ax(1),'p(regular)')
ylabel(ax(2),'CV(p)')
ax(2).YLim(1) = 0;
disp(N)

figlib.pretty()
figlib.label('FontSize',28,'XOffset',-.03,'YOffset',-.03)




figlib.saveall('Location',display.saveHere,'Format','pdf')
init()