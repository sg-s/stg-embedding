

% get the baseline data 
close all

% get data
if ~exist('data','var')
	data = sourcedata.getAllData();
	data = sourcedata.filter(data,sourcedata.DataFilter.Baseline);

	% we're going to convert back into a structure array
	[alldata, data] = sourcedata.combine(data);

	% compute sub-dominant period
	DataSize = length(alldata.mask);
	for i = 1:DataSize
		offset = nanmin([nanmin(alldata.PD(i,:)) nanmin(alldata.LP(i,:))]);
		alldata.PD(i,:) = alldata.PD(i,:) - offset;
		alldata.LP(i,:) = alldata.LP(i,:) - offset;
	end

	metricsPD = sourcedata.ISI2DominantPeriod(alldata.PD,alldata.PD_PD);
	metricsLP = sourcedata.ISI2DominantPeriod(alldata.LP,alldata.LP_LP);

end


metricsLP.DominantPeriod(metricsLP.DominantPeriod>5) = NaN;
metricsPD.DominantPeriod(metricsPD.DominantPeriod>5) = NaN;

metricsLP.Maximum = nanmax(alldata.LP_LP,[],2);
metricsPD.Maximum = nanmax(alldata.PD_PD,[],2);

% drawing constants
lp_color = color.aqua('red');
pd_color = color.aqua('indigo');

show_this = 1;

spikes = alldata.LP(show_this,:);
isis = alldata.LP_LP(show_this,:);

figure('outerposition',[300 300 901 1111],'PaperUnits','points','PaperSize',[901 1111]); hold on
subplot(6,1,1); hold on
neurolib.raster(alldata.PD(show_this,:),'Color',pd_color,'center',false,'deltat',1)
neurolib.raster(alldata.LP(show_this,:),'Color',lp_color,'yoffset',1,'center',false,'deltat',1)

subplot(6,2,3); hold on
plot(alldata.LP(show_this,:),alldata.LP_LP(show_this,:),'.','Color',lp_color)
xlabel('Time (s)')
ylabel('LP_{ISI} (s)')
set(gca,'YScale','log','YLim',[1e-2 1e0])

subplot(6,2,4); hold on
time = linspace(0,20,2e3);
this_spikes = spikes(~isnan(spikes));
this_isis = isis(~isnan(isis));
this_spikes = this_spikes(1:length(this_isis));
Y = interp1(this_spikes,this_isis,time);
acf = autocorr(Y,500); % 5 seconds
time = linspace(0,5,501);
plot(time,acf,'Color',lp_color)








subplot(3,2,3); hold on
plotlib.scatterhist(metricsLP.Maximum,metricsLP.DominantPeriod,'Color',lp_color)


subplot(3,2,4); hold on
plotlib.scatterhist(metricsLP.ACF_values,metricsLP.DominantPeriod,'Color',lp_color)


f_LP = sum(~isnan(alldata.LP),2)/20;
f_PD = sum(~isnan(alldata.PD),2)/20;
subplot(3,2,5); hold on
plotlib.scatterhist(f_LP,f_PD)


% estimate duty cycles
DCLP = metricsLP.DominantPeriod - metricsLP.Maximum;
DCLP(DCLP<0 | DCLP>1 | metricsLP.ACF_values < .8) = NaN;
DCPD = metricsPD.DominantPeriod - metricsPD.Maximum;
DCPD(DCPD<0 | DCPD>1 | metricsPD.ACF_values < .8) = NaN;

subplot(3,2,6); hold on
plotlib.scatterhist(DCLP,DCPD)

 figlib.pretty('PlotLineWidth',1)