

close all
init()

% get sea surface temperatures
S = SeaSurfaceTemperature;
S.after = '01-Jan-2013';
S.before = '01-Dec-2019';

surface_temps = S.fetch;

% load dates of experiments
load date.mat

% convert dates into day of year
ndays = [31 28 31 30 31 30 31 31 30 31 30 31];
ndays = [0 cumsum(ndays)];


T_PD_mean = NaN(length(unique_exps),1);
T_PD_std = NaN(length(unique_exps),1);
Date = repmat(datetime(),length(unique_exps),1);

PD_dc = NaN(length(unique_exps),1);

p_normal_mean = NaN*T_PD_mean;
temperature = NaN*T_PD_mean;

for i = 1:length(unique_exps)

	if any(basedata.LP_channel(basedata.experiment_idx == unique_exps(i)) == 'LP')
		continue
	end

	if any(basedata.PD_channel(basedata.experiment_idx == unique_exps(i)) == 'PD')
		continue
	end

	if isnan(dates(i))
		continue
	end

	this_date = mat2str(dates(i));
	

	

	[~,use_this]=min(abs(datetime(this_date,'Format','yyyyMMdd') - surface_temps.Date));

	temperature(i) = surface_temps.Temperature(use_this);

	Date(i) = datetime(this_date,'Format','yyyyMMdd');


	% remove the year
	temp = datevec(Date(i));
	Date(i) = Date(i) - calyears(temp(1));


	this_T = basemetrics.PD_burst_period(basedata.experiment_idx == unique_exps(i) & basedata.idx == 'normal');
	T_PD_mean(i) = nanmean(this_T);
	T_PD_std(i) = nanstd(this_T);


	this_PD_dc = basemetrics.PD_duty_cycle(basedata.experiment_idx == unique_exps(i) & basedata.idx == 'normal');
	PD_dc(i) = nanmean(this_PD_dc);

	p_normal_mean(i) = mean(basedata.idx(basedata.experiment_idx == unique_exps(i)) == 'normal');

end



rm_this = isnan(T_PD_mean) | isnan(PD_dc);
Date(rm_this) = [];
PD_dc(rm_this) = [];
T_PD_mean(rm_this) = [];
p_normal_mean(rm_this) = [];
temperature(rm_this) = [];

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

subplot(3,3,1:2); hold on
plot(Date,T_PD_mean,'.','MarkerSize',10)
set(gca,'YLim',[ 0 2])
ylabel('T_{PD} (s)')


subplot(3,3,3); hold on
plot(temperature,T_PD_mean,'k.','MarkerSize',10)
set(gca,'YLim',[0 2],'XLim',[0 23])
[~,p]=corr(temperature,T_PD_mean,'Type','Spearman');
text(10,.3,['\itp=' mat2str(p,2)])


% duty cycles of PD
subplot(3,3,4:5); hold on
plot(Date,PD_dc,'.','MarkerSize',10)
ylabel('PD duty cycle')
set(gca,'YLim',[ 0 .5])



subplot(3,3,6); hold on
plot(temperature,PD_dc,'k.','MarkerSize',10)
set(gca,'YLim',[0 .5],'XLim',[0 23])
[~,p]=corr(temperature,PD_dc,'Type','Spearman');
text(10,.3,['\itp=' mat2str(p,2)])



subplot(3,3,7:8); hold on
plot(Date,p_normal_mean,'.','MarkerSize',10)
xlabel('Day of year')
ylabel('p(normal)')


subplot(3,3,9); hold on
plot(temperature,p_normal_mean,'k.','MarkerSize',10)
xlabel('Sea temperature (C)')
[~,p]=corr(temperature,p_normal_mean,'Type','Spearman');
set(gca,'YLim',[0 1],'XLim',[0 23])
text(20,.5,['\itp=' mat2str(p,2)])

figlib.pretty()



% cleanup
figlib.saveall
init()