
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



colors = display.colorscheme(alldata.idx);





figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on


ax.experimenter = subplot(3,3,1); hold on
[means, group_idx] = analysis.probStateGroupedBy(alldata, 'normal', 'experimenter');
C = lines;
group_idx = removecats(group_idx);
experimenters = unique(group_idx);
for i = 1:length(experimenters)
	[S,P]=plotlib.raincloud(means(group_idx == experimenters(i)),'YOffset',i*2,'Color',C(i,:));
	P.MarkerSize = 10;
end
group_idx = removecats(group_idx);
set(gca,'YTick',[2:2:2*length(experimenters)],'YTickLabel',cellfun(@char,categories(experimenters),'UniformOutput',false))


set(gca,'XAxisLocation','top')
xlabel('p(normal)')



% does recording type correlate with normal behavior? 

ax.LP_extra = subplot(3,3,4); hold on
temp = structlib.purge(alldata,alldata.LP_channel == 'gpn');
[means, group_idx] = analysis.probStateGroupedBy(temp, 'normal', 'LP_channel');

C = [intra_color; .3 .4 .7; ; extra_color];

groups = unique(group_idx);
% reorder groups for asethetics
groups = [groups(2); groups(1); groups(3)];

for i = 1:length(groups)
	[~, shade(i)] = display.plotCDFWithError(means(group_idx==groups(i)),C(i,:));
	lines(i) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',C(i,:),'MarkerFaceColor',C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end

set(gca,'XTickLabel',{},'XLim',[0 1],'YLim',[0 1])
legend(lines,cellfun(@char,{groups},'UniformOutput',false),'Location','northwest')

[~,p]=kstest2(means(group_idx=='LP'),means(group_idx~='LP'));
th = text(.35,.85,['\itp = ' mat2str(p,2)]);

% add some lines to indicate data grouping
ph = plot(ax.LP_extra,[.27 .33],[.75 .75],'k','HandleVisibility','off');
ph = plot(ax.LP_extra,[.27 .33],[.92 .92],'k','HandleVisibility','off');
ph = plot(ax.LP_extra,[.33 .33],[.75 .92],'k','HandleVisibility','off');
ph = plot(ax.LP_extra,[.27 .27],[.67 .83],'k','HandleVisibility','off');



C = [ extra_color; intra_color];
subplot(3,3,7); hold on
[means, group_idx] = analysis.probStateGroupedBy(alldata, 'normal', 'PD_channel');
groups = unique(group_idx);
clear lines shade
for i = 1:length(groups)
	[~, shade(i)] = display.plotCDFWithError(means(group_idx==groups(i)),C(i,:));
	lines(i) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',C(i,:),'MarkerFaceColor',C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end

legend(lines,cellfun(@char,{groups},'UniformOutput',false),'Location','northwest')
xlabel('p(normal)')
set(gca,'XLim',[0 1],'YLim',[0 1])

[~,p]=kstest2(means(group_idx=='PD'),means(group_idx~='PD'));
th = text(.1,.8,['\itp = ' mat2str(p,2)]);











% make treemaps to show distribution of all states

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

























ax.PD01 = subplot(4,3,3); hold on

temp = structlib.purge(alldata,alldata.LP_channel == 'LP' );
temp.PD_channel(temp.PD_channel == 'PD') = 'PD-intra';
temp.PD_channel(temp.PD_channel ~= 'PD-intra') = 'PD-extra';

[means, group_idx] = analysis.probStateGroupedBy(temp, 'PD-01', 'PD_channel');

C = [intra_color; extra_color];
groups = categories(removecats(group_idx));
for i = 1:length(groups)
	[~, shade(i)] = display.plotCDFWithError(means(group_idx==groups{i}),C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end
xlabel('p(PD-01)')
lines(1) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',intra_color,'MarkerFaceColor',intra_color);
lines(2) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',extra_color,'MarkerFaceColor',extra_color);
legend(lines,{'PD-intra','PD-extra'},'Location','southeast')
[~,p]=kstest2(means(group_idx=='PD-intra'),means(group_idx=='PD-extra'));
text(.7,.6,['\itp = ' mat2str(p,2)]);
ax.PD01.XLim = [0 1];




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
	[~, shade(i)] = display.plotCDFWithError(means(group_idx==groups{i}),C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end
lines(1) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',intra_color,'MarkerFaceColor',intra_color);
lines(2) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',extra_color,'MarkerFaceColor',extra_color);
legend(lines,{'LP-intra','LP-extra'},'Location','southeast')
xlabel('p(LP-01)')
[~,p]=kstest2(means(group_idx=='LP-intra'),means(group_idx=='LP-extra'));
text(.7,.6,['\itp = ' mat2str(p,2)]);
ax.LP01.XLim = [0 1];











% show how the burst periods change if we switch from intra to extra
clear L lh
ax.T_PD = subplot(4,3,9); hold on
X = metricsPD.DominantPeriod(alldata.PD_channel == 'PD');
X = analysis.averageBy(X,alldata.experiment_idx(alldata.PD_channel == 'PD'));
display.plotCDFWithError(X, intra_color);



Y = metricsPD.DominantPeriod(alldata.PD_channel ~= 'PD');
Y = analysis.averageBy(Y,alldata.experiment_idx(alldata.PD_channel ~= 'PD'));
display.plotCDFWithError(Y, extra_color);
xlabel('T_{PD} (s)')

% fake plots for legend
lines(1) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',intra_color,'MarkerFaceColor',intra_color);
lines(2) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',extra_color,'MarkerFaceColor',extra_color);
legend(lines,{'PD-intra','PD-extra'},'Location','southeast')
[~,p]=kstest2(X,Y);
text(2,.6,['\itp = ' mat2str(p,2)]);
ax.T_PD.XLim = [0 3];




clear lines
ax.T_LP =subplot(4,3,12); hold on
X = metricsLP.DominantPeriod(alldata.LP_channel == 'LP');
X = analysis.averageBy(X,alldata.experiment_idx(alldata.LP_channel == 'LP'));
display.plotCDFWithError(X, intra_color);

Y = metricsLP.DominantPeriod(alldata.LP_channel ~= 'LP');
Y = analysis.averageBy(Y,alldata.experiment_idx(alldata.LP_channel ~= 'LP'));
display.plotCDFWithError(Y, extra_color);
xlabel('T_{LP} (s)')

% fake plots for legend
lines(1) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',intra_color,'MarkerFaceColor',intra_color);
lines(2) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',extra_color,'MarkerFaceColor',extra_color);
legend(lines,{'LP-intra','LP-extra'},'Location','southeast')

[~,p]=kstest2(X,Y);
text(2,.6,['\itp = ' mat2str(p,2)]);




figlib.pretty('FontSize',16)
ax.experimenter.YLim = [0 14];
ax.PD01.XColor = colors('PD-01');
ax.LP01.XColor = colors('LP-01');





% scale some plots and let them breate
ax.LP01.Position(4) =  ax.LP01.Position(4)*.9;
ax.PD01.Position(4) =  ax.PD01.Position(4)*.9;
ax.T_PD.Position(4) =  ax.T_PD.Position(4)*.9;
ax.T_LP.Position(4) =  ax.T_LP.Position(4)*.9;





th.Position = [.35 .85];


return

% load dates
load date.mat

load('historical_temperatures.mat','T')

% convert dates into day of year
ndays = [31 28 31 30 31 30 31 31 30 31 30 31];
ndays = [0 cumsum(ndays)];


T_PD_mean = NaN(length(unique_exps),1);
T_PD_std = NaN(length(unique_exps),1);
DayOfYear = NaN*T_PD_mean;

p_normal_mean = NaN*T_PD_mean;
temperature = NaN*T_PD_mean;

for i = 1:length(unique_exps)

	this_date = dates(i);
	if isnan(this_date)
		continue
	end

	if any(alldata.LP_channel(alldata.experiment_idx == unique_exps(i)) == 'LP')
		continue
	end

	if any(alldata.PD_channel(alldata.experiment_idx == unique_exps(i)) == 'PD')
		continue
	end

	this_date = mat2str(this_date);

	temperature(i) = T.TMAX(find(T.DATE == datetime(datevec([this_date(5:6) '-' this_date(7:8) '-' this_date(1:4)]))));

	DayOfYear(i) = ndays(str2double(this_date(5:6)))+str2double(this_date(7:end));


	this_T = metricsPD.DominantPeriod(alldata.experiment_idx == unique_exps(i) & metricsPD.ACF_values > .9);
	T_PD_mean(i) = nanmean(this_T);
	T_PD_std(i) = nanstd(this_T);

	p_normal_mean(i) = mean(alldata.idx(alldata.experiment_idx == unique_exps(i)) == 'normal');
	p_normal_std(i) = std(alldata.idx(alldata.experiment_idx == unique_exps(i)) == 'normal')/sqrt(length(alldata.idx(alldata.experiment_idx == unique_exps(i)) == 'normal'));
end


rm_this = isnan(DayOfYear) | isnan(T_PD_mean);
DayOfYear(rm_this) = [];
T_PD_mean(rm_this) = [];
T_PD_std(rm_this) = [];
p_normal_mean(rm_this) = [];
p_normal_std(rm_this) = [];
temperature(rm_this) = [];

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

subplot(2,3,1:2); hold on
errorbar(DayOfYear,T_PD_mean,T_PD_std,'o')

ylabel('T_{PD} (s)')
set(gca,'XLim',[1 365])

subplot(2,3,3); hold on
plot(temperature,T_PD_mean,'ko')
set(gca,'YLim',[.2 1.6])
[~,p]=corr(temperature,T_PD_mean);
text(80,.3,['\itp=' mat2str(p,2)])

subplot(2,3,4:5); hold on
errorbar(DayOfYear,p_normal_mean,p_normal_std,'o')
xlabel('Day of year')
ylabel('p(normal)')
set(gca,'XLim',[1 365])


subplot(2,3,6); hold on
plot(temperature,p_normal_mean,'ko')
xlabel('Temperature at Logan (F)')
[~,p]=corr(temperature,p_normal_mean);
set(gca,'YLim',[0 1])
text(80,.5,['\itp=' mat2str(p,2)])

figlib.pretty()






