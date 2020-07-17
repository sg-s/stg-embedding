
close all
clearvars -except data alldata metricsPD metricsLP

% constants
extra_color = [.1 .1 .1];
intra_color = [.9 0 0];

% get data
if ~exist('metricsPD','var')


	% compute sub-dominant period
	DataSize = length(alldata.mask);
	for i = 1:DataSize
		offset = nanmin([nanmin(alldata.PD(i,:)) nanmin(alldata.LP(i,:))]);
		alldata.PD(i,:) = alldata.PD(i,:) - offset;
		alldata.LP(i,:) = alldata.LP(i,:) - offset;
	end

	metricsPD = sourcedata.ISI2DominantPeriod(alldata.PD,alldata.PD_PD);
	metricsLP = sourcedata.ISI2DominantPeriod(alldata.LP,alldata.LP_LP);

	metricsPD.DominantPeriod(metricsPD.DominantPeriod==20) = NaN;
	metricsLP.DominantPeriod(metricsLP.DominantPeriod==20) = NaN;

end


figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on


ax.experimenter = subplot(3,3,1); hold on
[means, group_idx] = analysis.probStateGroupedBy(alldata, 'normal', 'experimenter');



violinplot(means,group_idx);
set(gca,'View',[90 -90],'XLim',[0 7])
set(gca,'YAxisLocation','right')
ylabel('p(normal)')


% does recording type correlate with behaviour? 

subplot(3,3,4); hold on
temp = structlib.purge(alldata,alldata.LP_channel == 'gpn');
[means, group_idx] = analysis.probStateGroupedBy(temp, 'normal', 'LP_channel');

C = [.3 .4 .7; intra_color; extra_color];

groups = unique(group_idx);
for i = 1:length(groups)
	[lines(i), shade(i)] = display.plotCDFWithError(means(group_idx==groups(i)),C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end


set(gca,'XTickLabel',{},'XLim',[0 1],'YLim',[0 1])

legend(lines,cellfun(@char,{groups},'UniformOutput',false),'Location','northwest')



C = [ extra_color; intra_color];
subplot(3,3,7); hold on
[means, group_idx] = analysis.probStateGroupedBy(alldata, 'normal', 'PD_channel');
groups = unique(group_idx);
clear lines shade
for i = 1:length(groups)
	[lines(i), shade(i)] = display.plotCDFWithError(means(group_idx==groups(i)),C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end

legend(lines,cellfun(@char,{groups},'UniformOutput',false),'Location','northwest')


xlabel('p(normal)')

set(gca,'XLim',[0 1],'YLim',[0 1])



% make stacked bar charts of different states based on what's on each channel

labels = {'LP/PD','LP/pdn','PD/lpn/lvn','pdn/lpn','pdn/lvn'};


ShowThese = zeros(length(alldata.idx),5);
ShowThese(:,1) = alldata.LP_channel == 'LP' & alldata.PD_channel == 'PD';
ShowThese(:,2) = alldata.LP_channel == 'LP' & alldata.PD_channel == 'pdn';
ShowThese(:,3) = (alldata.LP_channel == 'lvn' | alldata.LP_channel == 'lpn') & alldata.PD_channel == 'PD';
ShowThese(:,4) = alldata.LP_channel == 'lpn' & alldata.PD_channel == 'pdn';
ShowThese(:,5) = alldata.LP_channel == 'lvn' & alldata.PD_channel == 'pdn';


cats = categories(alldata.idx);
for i = 1:5
	subplot(5,3,3*(i)-1); hold on
	[h,P] = display.plotStateDistributionByPrep(alldata,ShowThese(:,i));
	delete(h)

	if i == 1
		ylabel('Preparation')
	end
	set(gca,'XColor','w')
	

	P = mean(P);

	display.mondrian(P,display.colorscheme(cats),cats);
	text(.2,.5,[mat2str(P(1)*100,2) '%'],'Color','w','FontSize',24)
	title(labels{i},'FontWeight','normal')
end


% show how the burst periods change if we switch from intra to extra
clear L lh
ax.T_PD = subplot(4,3,9); hold on
X = metricsPD.DominantPeriod(alldata.PD_channel == 'PD');
X = analysis.averageBy(X,alldata.experiment_idx(alldata.PD_channel == 'PD'));
[lines, shade] = display.plotCDFWithError(X, intra_color);



Y = metricsPD.DominantPeriod(alldata.PD_channel ~= 'PD');
Y = analysis.averageBy(Y,alldata.experiment_idx(alldata.PD_channel ~= 'PD'));
[lines, shade] = display.plotCDFWithError(Y, extra_color);
xlabel('T_{PD} (s)')





ax.T_LP =subplot(4,3,12); hold on
X = metricsLP.DominantPeriod(alldata.LP_channel == 'LP');
X = analysis.averageBy(X,alldata.experiment_idx(alldata.LP_channel == 'LP'));
[lines, shade] = display.plotCDFWithError(X, intra_color);

Y = metricsLP.DominantPeriod(alldata.LP_channel ~= 'LP');
Y = analysis.averageBy(Y,alldata.experiment_idx(alldata.LP_channel ~= 'LP'));
[lines, shade] = display.plotCDFWithError(Y, extra_color);
xlabel('T_{LP} (s)')

















ax.PD01 = subplot(4,3,3); hold on

temp = structlib.purge(alldata,alldata.LP_channel == 'LP' );
temp.PD_channel(temp.PD_channel == 'PD') = 'PD-intra';
temp.PD_channel(temp.PD_channel ~= 'PD-intra') = 'PD-extra';

[means, group_idx] = analysis.probStateGroupedBy(temp, 'PD-01', 'PD_channel');

C = [intra_color; extra_color];
groups = categories(removecats(group_idx));
for i = 1:length(groups)
	[lines(i), shade(i)] = display.plotCDFWithError(means(group_idx==groups{i}),C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end
xlabel('p(PD-01)')
legend(lines,groups,'Location','southeast')




ax.LP01 = subplot(4,3,6); hold on
temp = structlib.purge(alldata,alldata.PD_channel == 'PD' );
temp.LP_channel(temp.LP_channel == 'LP') = 'LP-intra';
temp.LP_channel(temp.LP_channel == 'lpn') = 'LP-extra';
temp.LP_channel(temp.LP_channel == 'lvn') = 'LP-extra';

temp = structlib.purge(temp,temp.LP_channel == 'gpn' );
[means, group_idx] = analysis.probStateGroupedBy(temp, 'LP-01', 'LP_channel');
C = [intra_color; extra_color];
groups = categories(removecats(group_idx));
for i = 1:length(groups)
	[lines(i), shade(i)] = display.plotCDFWithError(means(group_idx==groups{i}),C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end
legend(lines,groups,'Location','southeast')
xlabel('p(LP-01)')

figlib.pretty('FontSize',16)


colors = display.colorscheme(alldata.idx);
ax.PD01.XColor = colors('PD-01');


ax.LP01.XColor = colors('LP-01');

% scale some plots and let them breate
ax.LP01.Position(4) =  ax.LP01.Position(4)*.9;
ax.PD01.Position(4) =  ax.PD01.Position(4)*.9;
ax.T_PD.Position(4) =  ax.T_PD.Position(4)*.9;
ax.T_LP.Position(4) =  ax.T_LP.Position(4)*.9;