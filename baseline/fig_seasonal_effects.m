
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
