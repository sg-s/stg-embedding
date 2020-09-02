

close all
init()

% get all experimental dates
load('../cache/recording_dates.mat','ExpDates')


S = SeaSurfaceTemperature;

for i = 1:length(ExpDates)
	S.Date = ExpDates(i).date;
	data = S.fetch;
	ExpDates(i).Temperature = data.Temperature;
end


time_since_decentralization = analysis.timeSinceDecentralization(decdata);


% measure the metrics for these experiments
for i = 1:length(ExpDates)

	ExpDates(i).p_normal = NaN;
	ExpDates(i).p_normal_dec = NaN;
	ExpDates(i).PD_dc = NaN;
	ExpDates(i).PD_mean = NaN;
	ExpDates(i).PD_std = NaN;
	ExpDates(i).T_change = NaN;
	ExpDates(i).PD_f_change = NaN;
	ExpDates(i).LP_f_change = NaN;

	if any(basedata.LP_channel(basedata.experiment_idx == ExpDates(i).exp) == 'LP')
		continue
	end

	if any(basedata.PD_channel(basedata.experiment_idx == ExpDates(i).exp) == 'PD')
		continue
	end


	this_T = basemetrics.PD_burst_period(basedata.experiment_idx == ExpDates(i).exp & basedata.idx == 'normal');
	ExpDates(i).PD_mean = nanmean(this_T);
	ExpDates(i).PD_std = nanstd(this_T);


	this_PD_dc = basemetrics.PD_duty_cycle(basedata.experiment_idx == ExpDates(i).exp & basedata.idx == 'normal');
	ExpDates(i).PD_dc = nanmean(this_PD_dc);

	ExpDates(i).p_normal = mean(basedata.idx(basedata.experiment_idx == ExpDates(i).exp) == 'normal');


	% compute decentralized metrics


	this_exp = decdata.experiment_idx == ExpDates(i).exp;
	dec =  time_since_decentralization > 0 & time_since_decentralization < 20*30 & this_exp;
	not_dec = time_since_decentralization < 0 & this_exp;




	ExpDates(i).p_normal_dec = mean(decdata.idx(dec) == 'normal'); 

	T_before = nanmean(decmetrics.PD_burst_period(not_dec));
	T_after = nanmean(decmetrics.PD_burst_period(dec));
	ExpDates(i).T_change = T_after - T_before;

	PD_f_before = nanmean(sum(~isnan(decdata.PD(not_dec,:)),2))/20;
	PD_f_after = nanmean(sum(~isnan(decdata.PD(dec,:)),2))/20;
	ExpDates(i).PD_f_change = PD_f_after - PD_f_before;

	LP_f_before = nanmean(sum(~isnan(decdata.LP(not_dec,:)),2))/20;
	LP_f_after = nanmean(sum(~isnan(decdata.LP(dec,:)),2))/20;
	ExpDates(i).LP_f_change = LP_f_after - LP_f_before;
end




figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

ax = subplot(3,3,1:3); hold on
plot([ExpDates.date],[ExpDates.Temperature],'k.','MarkerSize',10)
ax.XLim(1) = datetime('2013','InputFormat','yyyy');
ylabel('Sea Surface Temp (C)')
xlabel('Experiment date')

xx = [ExpDates.date];
yy = [ExpDates.Temperature];
xx = datenum(xx);
ff = fit(xx(:),yy(:),'smoothingspline','SmoothingParam',0.0001);
xs = linspace(min(xx),max(xx),1e3);
plot(datetime(datestr(xs)),ff(xs),'r')


subplot(3,3,4); hold on
display.scatterWithCorrelation([ExpDates.Temperature],[ExpDates.PD_mean]);
ylabel('<T_{PD}> (s)')
set(gca,'XAxisLocation','top')

subplot(3,3,5); hold on
display.scatterWithCorrelation([ExpDates.Temperature],[ExpDates.PD_dc]);
ylabel('<DC_{PD}>')
set(gca,'XAxisLocation','top')

subplot(3,3,6); hold on
display.scatterWithCorrelation([ExpDates.Temperature],[ExpDates.p_normal]);
ylabel('<p(normal)>')
set(gca,'XAxisLocation','top')

subplot(3,3,7); hold on
display.scatterWithCorrelation([ExpDates.Temperature],[ExpDates.p_normal_dec]);

ylabel('<p(normal)> (decentralized)')


subplot(3,3,8); hold on
display.scatterWithCorrelation([ExpDates.Temperature],[ExpDates.T_change]);
ylabel('\DeltaT_{PD} (s)')
xlabel('Sea Surface Temperature (C)')

subplot(3,3,9); hold on
display.scatterWithCorrelation([ExpDates.Temperature],[ExpDates.PD_f_change]);

ylabel('\Deltaf_{PD} (Hz)')


figlib.pretty('LineWidth',1)

ax.Position = [.13 .75 .77 .2];


figlib.label('XOffset',-.001,'FontSize',28,'YOffset',.01)

% cleanup
figlib.saveall('Location',display.saveHere)

init()