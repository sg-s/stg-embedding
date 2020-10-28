

% get the baseline data 
close all
clearvars ax

init()


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
ax(1) = subplot(6,1,1); hold on
neurolib.raster(alldata.PD(show_this,:),'Color',pd_color,'center',false,'deltat',1)
neurolib.raster(alldata.LP(show_this,:),'Color',lp_color,'yoffset',1,'center',false,'deltat',1)
ax(1).XLim = [0 10];
plot(ax(1),[0 20],[.5 .5],'Color',pd_color)
plot(ax(1),[0 20],[1.5 1.5],'Color',lp_color)
text(-.5,.5,'PD','Color',pd_color);
text(-.5,1.5,'LP','Color',lp_color);

ax(2) = subplot(6,2,3); hold on
plot(alldata.LP(show_this,:),alldata.LP_LP(show_this,:),'o-','Color',lp_color)
xlabel('Time (s)')
ylabel('LP_{ISI} (s)')
set(gca,'YScale','log','YLim',[1e-2 1e0],'XLim',[0 5])


ax(3) = subplot(6,2,4); hold on
time = linspace(0,20,2e3);
this_spikes = spikes(~isnan(spikes));
this_isis = isis(~isnan(isis));
this_spikes = this_spikes(1:length(this_isis));
Y = interp1(this_spikes,this_isis,time);
acf = autocorr(Y,500); % 5 seconds
time = linspace(0,5,501);
plot(time,acf,'Color',lp_color,'LineWidth',2.5)
xh = xlabel('Lag (s)');
ylabel('ACF')
ax(3).YLim = [-1 1];
[~,locs]=findpeaks(acf);
ax(3).XTick = time(locs);
ax(3).XLim = [0 2];
ax(3).XAxisLocation = 'origin';
xh.Position = [2.2 0.1];


ax(4) = subplot(3,2,3); hold on
plotlib.scatterhist(metricsLP.Maximum,metricsLP.DominantPeriod,'Color',lp_color)
xlabel('Max(ISI_{LP}) (s)')
ylabel('T_{LP} (s)')

ax(5) = subplot(3,2,4); hold on
plotlib.scatterhist(metricsLP.ACF_values,metricsLP.DominantPeriod,'Color',lp_color)
ylabel('T_{LP} (s)')
xlabel('Peak ACF')

f_LP = sum(~isnan(alldata.LP),2)/20;
f_PD = sum(~isnan(alldata.PD),2)/20;
ax(6) = subplot(3,2,5); hold on
plotlib.scatterhist(f_LP,f_PD)
xlabel('<f>_{LP} (Hz)')
ylabel('<f>_{PD} (Hz)')

% estimate duty cycles
DCLP = metricsLP.DominantPeriod - metricsLP.Maximum;
DCLP(DCLP<0 | DCLP>1 | metricsLP.ACF_values < .8) = NaN;
DCPD = metricsPD.DominantPeriod - metricsPD.Maximum;
DCPD(DCPD<0 | DCPD>1 | metricsPD.ACF_values < .8) = NaN;

ax(7) = subplot(3,2,6); hold on
plotlib.scatterhist(DCLP,DCPD)
xlabel('DC_{LP}')
ylabel('DC_{PD}')


figlib.pretty('PlotLineWidth',1,'LineWidth',1)

ax(7).XTick(mathlib.aeq(ax(7).XTick,.6)) = [];
ax(5).XTickLabel{end} = '.98';
ax(4).XTickLabel{end} = '4.5';
axis(ax(1),'off')
ax(6).YTick = [0:10:40 43.95];