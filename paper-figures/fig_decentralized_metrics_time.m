% plots metrics in decentralized preps
% as a function of time

init
close all


LP_color = color.aqua('red');
PD_color = color.aqua('indigo');

time_since_decentralization = analysis.timeSinceDecentralization(decdata);
all_preps = unique(decdata.experiment_idx);

time = -600:20:1800;


figure('outerposition',[300 300 1401 999],'PaperUnits','points','PaperSize',[1401 999]); hold on



% average metrics by prep
baseline_averaged_metrics = struct;
decentralized_averaged_metrics = struct;
fn = fieldnames(decmetrics);
for i = 1:length(fn)
	temp = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, decmetrics.(fn{i}), time);
	baseline_averaged_metrics.(fn{i}) = nanmean(temp(:,time<0),2);
	decentralized_averaged_metrics.(fn{i}) = nanmean(temp(:,time>0),2);
end






% change in PD firing rate


all_PDf = sum(~isnan(decdata.PD),2)/20;
all_LPf = sum(~isnan(decdata.LP),2)/20;

PDf = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, all_PDf, time);
LPf = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, all_LPf, time);


PD_dc = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, decmetrics.PD_duty_cycle, time);
LP_dc = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, decmetrics.LP_duty_cycle, time);

LP_on = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, decmetrics.LP_phase_on, time);
LP_off = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, decmetrics.LP_phase_off, time);


PD_T = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, decmetrics.PD_burst_period, time);
LP_T = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, decmetrics.LP_burst_period, time);

% normalize
PD_T_norm = analysis.normalizeMatrix(PD_T,time<0);
LP_T_norm = analysis.normalizeMatrix(LP_T,time<0);

PDf = analysis.normalizeMatrix(PDf,time<0);
LPf = analysis.normalizeMatrix(LPf,time<0);





% raincloud of all normalized metrics
ax(1) = subplot(2,3,1); hold on
fn = fieldnames(decmetrics);
fn = setdiff(fn,{'PD_nspikes','LP_nspikes','PD_delay_on','LP_burst_period','LP_durations','PD_durations','PD_phase_on'});
L = {};
for i = 1:length(fn)
	if any(strfind(fn{i},'PD'))
		C = PD_color;
	else
		C = LP_color;
	end
	X = decentralized_averaged_metrics.(fn{i}) - baseline_averaged_metrics.(fn{i});
	plotlib.raincloud(X,'YOffset',2*i,'Height',.5,'Color',C);
	L{i} = strrep(fn{i},'_',' ');

	if any(strfind(L{i},'duty')) | any(strfind(L{i},'phase'))
	else
		L{i} = [L{i} ' (s)'];
	end

	L{i} = ['\Delta' L{i}];

	[h,p]=ttest(X);
	if p*length(fn) < .05
		plot(max(X) + .2,2*i,'k*','MarkerSize',12);
	end
end
set(ax(1),'YTick',[2:2:2*length(fn)],'YTickLabel',L)
ax(1).YLim = [0 2*i+2];
ax(1).XLim = [-.5 1.2];





ax(2) = subplot(2,3,2); hold on
display.plotMetricsVsTime(time,nanmean(PDf),PD_color)
display.plotMetricsVsTime(time,nanmean(LPf),LP_color)
set(gca,'YLim',[0 5])
plot([min(time) max(time)],[1 1],':','Color',[.5 .5 .5])





ax(3) = subplot(2,3,3); hold on
display.plotMetricsVsTime(time,PD_T_norm,PD_color)
set(gca,'YLim',[0.9 2])
plot([min(time) max(time)],[1 1],':','Color',[.5 .5 .5])





% plot phases of things vs. periods
ax(4) = subplot(2,3,4); hold on
C = lines;
plot(nanmean(PD_T(:,time>0)),nanmean(LP_off(:,time>0)),'k.','MarkerSize',10)
plot(nanmean(PD_T(:,time<0)),nanmean(LP_off(:,time<0)),'.','Color',C(3,:),'MarkerSize',10)



plot(nanmean(PD_T(:,time>0)),nanmean(LP_on(:,time>0)),'k.','MarkerSize',10)
plot(nanmean(PD_T(:,time<0)),nanmean(LP_on(:,time<0)),'.','Color',C(2,:),'MarkerSize',10)


% fit lines
XX = linspace(0.1,2,1e3);
X = nanmean(PD_T(:,time<0)); X = X(:);
Y = nanmean(LP_off(:,time<0)); Y = Y(:);
ff = fit(X,Y,'poly1');

temp = (predint(ff,XX));
ph = plot(polyshape([XX fliplr(XX)]', [temp(:,1); flipud(temp(:,2))]));
ph.FaceColor = C(3,:);
uistack(ph,'bottom')
ph.LineStyle = 'none';


XX = linspace(0.1,2,1e3);
X = nanmean(PD_T(:,time<0)); X = X(:);
Y = nanmean(LP_on(:,time<0)); Y = Y(:);
ff = fit(X,Y,'poly1');

temp = (predint(ff,XX));
ph = plot(polyshape([XX fliplr(XX)]', [temp(:,1); flipud(temp(:,2))]));
ph.FaceColor = C(2,:);
uistack(ph,'bottom')
ph.LineStyle = 'none';



ax(4).YLim = [0 1];
ax(4).XLim = [.5 1.5];




ax(5) = subplot(2,3,5); hold on
display.plotMetricsVsTime(time,LP_on,LP_color)
display.plotMetricsVsTime(time,LP_off,LP_color)
set(gca,'YLim',[0 1])


ax(6) = subplot(2,3,6); hold on
display.plotMetricsVsTime(time,PD_dc,PD_color)
display.plotMetricsVsTime(time,LP_dc,LP_color)
set(gca,'YLim',[0.1 .4])


ax(2).XAxisLocation = 'top';
ax(3).YAxisLocation = 'right';
ax(3).XAxisLocation = 'top';
ax(6).YAxisLocation = 'right';

h = xlabel(ax(5),'Time since decentralized (s)');
h.Position = [2500 -.15];

h = xlabel(ax(2),'Time since decentralized (s)');
h.Position = [2500 5.7];

xlabel(ax(4),'Burst period (s)');
ylabel(ax(4),'Phase')

ylabel(ax(6),'Duty cycle')

ylabel(ax(3),'Burst period (fold change)')
ylabel(ax(2),'Firing rate (fold change)')

figlib.pretty()


% this init clears all the junk this script
init()