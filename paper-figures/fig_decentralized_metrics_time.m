% plots metrics in decentralized preps
% as a function of time

init
close all


colors = display.colorscheme(alldata.idx);

time_since_decentralization = analysis.timeSinceDecentralization(decdata);
all_preps = unique(decdata.experiment_idx);

time = -600:20:1800;


figure('outerposition',[300 300 1401 999],'PaperUnits','points','PaperSize',[1401 999]); hold on



% average metrics by prep
baseline_averaged_metrics = struct;
decentralized_averaged_metrics = struct;

baseline_cv_metrics = struct;
decentralized_cv_metrics = struct;

fn = fieldnames(decmetrics);
for i = 1:length(fn)

	this = decmetrics.(fn{i});
	this(decdata.idx ~= 'regular') = NaN;

	temp = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, this, time);
	baseline_averaged_metrics.(fn{i}) = nanmean(temp(:,time<0),2);
	decentralized_averaged_metrics.(fn{i}) = nanmean(temp(:,time>0 & time < 1e3),2);

	baseline_cv_metrics.(fn{i}) = nanstd(temp(:,time<0),[],2)./nanmean(temp(:,time<0),2);
	decentralized_cv_metrics.(fn{i}) = nanstd(temp(:,time>0),[],2)./nanmean(temp(:,time>0),2);
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

% there's a weird outlier, let's nuke it
LP_on(LP_on>1) = NaN;
LP_off(LP_off>1) = NaN;
decentralized_averaged_metrics.LP_phase_on(decentralized_averaged_metrics.LP_phase_on>1) = NaN;
decentralized_averaged_metrics.LP_phase_off(decentralized_averaged_metrics.LP_phase_off>1) = NaN;


PD_T = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, decmetrics.PD_burst_period, time);
LP_T = analysis.prepTimeMatrix(decdata.experiment_idx, time_since_decentralization, decmetrics.LP_burst_period, time);

% compare duty cycles
lp = nanmean(LP_dc(:,time>0),2) - nanmean(LP_dc(:,time<0),2);
pd = nanmean(PD_dc(:,time>0),2) - nanmean(PD_dc(:,time<0),2);
rm_this = isnan(lp) | isnan(pd);
lp(rm_this) = []; pd(rm_this) = [];


% normalize
PD_T_norm = analysis.normalizeMatrix(PD_T,time<0);
LP_T_norm = analysis.normalizeMatrix(LP_T,time<0);


% raincloud of all normalized metrics
ax(1) = subplot(2,3,1); hold on

fn = fieldnames(decmetrics);
fn = setdiff(fn,{'PD_nspikes','LP_nspikes','PD_delay_on','LP_burst_period','LP_durations','PD_durations','PD_phase_on'});
L = {};
MX = -1;
for i = 1:length(fn)
	if any(strfind(fn{i},'PD'))
		C = colors.PD;
	else
		C = colors.LP;
	end
	X = decentralized_averaged_metrics.(fn{i}) - baseline_averaged_metrics.(fn{i});
	plotlib.raincloud(X,'YOffset',2*i,'Height',.5,'Color',C);
	L{i} = strrep(fn{i},'_',' ');

	if any(strfind(L{i},'duty')) | any(strfind(L{i},'phase'))
	else
		L{i} = [L{i} ' (s)'];
	end

	L{i} = ['\Delta' L{i}];


	h = adtest(X);
	if h == 1
		disp('AD test says this is not Gaussian')
		p = statlib.pairedPermutationTest(decentralized_averaged_metrics.(fn{i}),baseline_averaged_metrics.(fn{i}));
	else
		[h,p]=ttest(X);
	end

	

	

	if p*length(fn) < .05
		plot(max(X) + .2,2*i,'k*','MarkerSize',12);
	end
	MX = max([MX; max(X)]);
end
set(ax(1),'YTick',[2:2:2*length(fn)],'YTickLabel',L)
ax(1).YLim = [0 2*i+2];
ax(1).XLim = [-.5 MX+.5];
h = plotlib.vertline(ax(1),0,'k--');
uistack(h,'bottom');
xlabel('Change in mean')


% raincloud of excess variability on decentralization
ax(4) = subplot(2,3,4); hold on
MX = -1;
for i = 1:length(fn)
	if any(strfind(fn{i},'PD'))
		C = colors.PD;
	else
		C = colors.LP;
	end
	X = decentralized_cv_metrics.(fn{i}) - baseline_cv_metrics.(fn{i});
	plotlib.raincloud(X,'YOffset',2*i,'Height',.5,'Color',C);
	L{i} = strrep(fn{i},'_',' ');

	if any(strfind(L{i},'duty')) | any(strfind(L{i},'phase'))
	else
		L{i} = [L{i} ' (s)'];
	end

	L{i} = ['\Delta' L{i}];


	p = statlib.pairedPermutationTest(decentralized_cv_metrics.(fn{i}),baseline_cv_metrics.(fn{i}));

	%[h,p]=ttest(X);
	if p*length(fn) < .05
		plot(max(X) + .2,2*i,'k*','MarkerSize',12);
	end
	MX = max([MX; max(X)]);
end
set(ax(4),'YTick',2:2:2*length(fn),'YTickLabel',L)
ax(4).YLim = [0 2*i+2];
h = plotlib.vertline(ax(4),0,'k--');
uistack(h,'bottom');
xlabel('Change in CV')




ax(2) = subplot(2,3,2); hold on
display.plotMetricsVsTime(time,(PDf),colors.PD)
display.plotMetricsVsTime(time,(LPf),colors.LP)
set(gca,'YLim',[0 11])






ax(5) = subplot(2,3,5); hold on
display.plotMetricsVsTime(time,PD_T_norm,colors.PD)
set(gca,'YLim',[0.9 2.5])
plot([min(time) max(time)],[1 1],':','Color',[.5 .5 .5])

size(PD_T_norm)
size(time)







ax(3) = subplot(2,3,3); hold on
display.plotMetricsVsTime(time,LP_on,colors.LP)
display.plotMetricsVsTime(time,LP_off,colors.LP)
set(gca,'YLim',[0 1])


ax(6) = subplot(2,3,6); hold on
display.plotMetricsVsTime(time,PD_dc,colors.PD)
display.plotMetricsVsTime(time,LP_dc,colors.LP)
set(gca,'YLim',[0 .4])



ax(3).YAxisLocation = 'right';
ax(6).YAxisLocation = 'right';

h = xlabel(ax(5),'Time since decentralization (s)');
h.Position = [2500 .65];

h = xlabel(ax(2),'Time since decentralization (s)');
h.Position = [2500 -1.5];

ylabel(ax(3),'Phase')
ylabel(ax(6),'Duty cycle')
ylabel(ax(5),'Burst period (fold change)')
ylabel(ax(2),'Firing rate (Hz)')

figlib.pretty()


ax(1).YTickLabel = L;

figlib.label('FontSize',30,'XOffset',-.02,'YOffset',-.0,'ColumnFirst',true)


text(ax(2),1e3,1,'LP','FontSize',20,'Color',colors.LP);
text(ax(2),1e3,6,'PD','FontSize',20,'Color',colors.PD);

text(ax(3),-500,.37,'LP on','FontSize',20,'Color',colors.LP);
text(ax(3),-500,.74,'LP off','FontSize',20,'Color',colors.LP);


figlib.saveall('Location',display.saveHere,'Format','pdf')

% this init clears all the junk this script
init()