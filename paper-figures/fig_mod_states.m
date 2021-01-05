
close all

init()


figure('outerposition',[300 300 1500 901],'PaperUnits','points','PaperSize',[1500 901]); hold on

clear ax

modnames = {'RPCH','proctolin','oxotremorine','serotonin'};



for i = 1:length(modnames)
	ax(i) = subplot(2,2,i); hold on

	axlib.label(ax(i),char(96+i),'XOffset',-.04,'FontSize',24);

	% find all preps where this mod is used
	preps = unique(moddata.experiment_idx(moddata.(modnames{i}) > 0));
	preps = moddata.slice(ismember(moddata.experiment_idx,preps) & moddata.decentralized);


	if length(preps.mask) == 0
		continue
	end

	% only use the last 5 minutes before mod on
	% to ignore transient effects of decentralization
	LastFiveMinutes = @(data)  ((1:length(data.mask)) - find(data.(modnames{i}) > 0,1,'first') + 15 ) > 0;

	T = analysis.forEachPrep(preps,LastFiveMinutes);
	preps = preps.slice(T);

	%preps = preps.slice(preps.PD_channel ~= 'PD' | preps.LP_channel ~= 'LP');


	display.pairedMondrian(ax(i),preps, preps.(modnames{i}) == 0, preps.(modnames{i}) > 0, 'decentralized', ['+' modnames{i}]);


end

figlib.pretty('FontSize',16)






% analysis of variability 
figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
clear ax


for i = 1:2
	ax(i) = subplot(1,2,i); hold on
	set(ax(i),'XTick',1:length(modnames),'XTickLabel',modnames,'XTickLabelRotation',45,'XLim',[0 5])
end
% compare prob. of normal prep by prep between mods

colors = display.colorscheme(alldata.idx);
cats = categories(alldata.idx);
N = 0;
for i = 1:length(modnames)

	preps = unique(moddata.experiment_idx(moddata.(modnames{i}) > 0));
	preps = moddata.slice(ismember(moddata.experiment_idx,preps) & moddata.decentralized);

	preps = preps.slice(preps.(modnames{i}) > 0);

	p = preps.probState;

	x = randn(size(p,1),1)*.1 + i;
	plot(ax(1),x,p(:,1),'o','MarkerFaceColor',colors.normal,'MarkerEdgeColor',colors.normal)

	for j = 1:size(p,2)
		y = nanstd(p(:,j))/nanmean(p(:,j));
		plot(ax(2),i + randn*.1, y,'o','MarkerFaceColor',colors(cats{j}),'MarkerEdgeColor',colors(cats{j}))
	end

	N = N + size(p,1);
end
ylabel(ax(1),'p(normal)')
ylabel(ax(2),'CV(p)')
ax(2).YLim(1) = 0;
disp(N)

figlib.pretty()
figlib.label('FontSize',28,'XOffset',-.03,'YOffset',-.03)




figlib.saveall('Location',display.saveHere)
init()