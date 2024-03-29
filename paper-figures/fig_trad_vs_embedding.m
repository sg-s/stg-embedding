

close all
init()

% show traditional metrics

% clean up a little bit
allmetrics.LP_phase_on(allmetrics.LP_phase_on>1) = NaN;
allmetrics.PD_burst_period(allmetrics.PD_burst_period>5) = NaN;
allmetrics.LP_burst_period(allmetrics.LP_burst_period>5) = NaN;
F = alldata.firingRates;

% drawing constants
lp_color = color.aqua('red');
pd_color = color.aqua('indigo');


figure('outerposition',[300 300 901 1222],'PaperUnits','points','PaperSize',[901 1222]); hold on
clear ax

% show the circuit

ax.circuit = subplot(4,4,1); hold on;
I = imread('circuit.png');
figlib.showImageInAxes(ax.circuit,I)



% hashes of examples
examples = {'903cb5a8f5433a52cc397f09cb7ffd64',
    'd837ae2690b8588ce7ee2912bfccff4b',
    '0e3b65f24ab42bab86564ef693c4cfb5',
    '334208844ff04688cc5dfa580ef68a95',
    '6e554e9ffb2d580cffa8c3bc9bc7d505',
    '07a41b92d6745e75680e115a395b539c'};

examples = find(ismember(hashes.alldata,examples));

% show the rasters of some example states
ax.rasters1 = subplot(4,4,2:3); hold on

for i = 1:3
	alldata.raster(examples(i),4*i)
end

% show the rasters of some example states
ax.rasters2 = subplot(4,4,4); hold on

for i = 4:length(examples)
	alldata.raster(examples(i),4*i)
end





% show the classical metrics


ax.burst_periods = subplot(4,3,4); hold on
X = allmetrics.PD_burst_period;
Y = allmetrics.LP_burst_period;
display.scatterWithExamples(alldata, examples, X, Y);
xlabel('T_{PD} (s)')
ylabel('T_{LP} (s)')




ax.duty_cycles = subplot(4,3,5); hold on
X = allmetrics.PD_duty_cycle;
Y = allmetrics.LP_duty_cycle;
display.scatterWithExamples(alldata, examples, X, Y);
xlabel('DC_{PD} (s)')
ylabel('DC_{LP} (s)')


ax.firing_rates = subplot(4,3,6); hold on
X = F(:,1);
Y = F(:,2);
display.scatterWithExamples(alldata, examples, X, Y);
xlabel('f_{PD} (Hz)')
ylabel('f_{LP} (Hz)')



% show embedding
ax.map = subplot(2,2,4); hold on

sh = plot(R(:,1)+randn(length(R),1)/2,R(:,2)+randn(length(R),1)/2,'.','MarkerSize',5,'Color',[.9 .9 .9]);



sh = scatter(R(:,1),R(:,2),5);

sh.Marker = 'o';
sh.MarkerEdgeColor = 'k';
sh.MarkerEdgeAlpha = .0;
sh.MarkerFaceColor = 'k';
sh.MarkerFaceAlpha = .05;


colors = display.colorscheme(alldata.idx);
for i = 1:length(examples)
	x = R(examples(i),1);
	y = R(examples(i),2);
	C = colors.(alldata.idx(examples(i)));
	plot(x,y,'.','MarkerSize',30,'Color',C)
end



figlib.pretty('LineWidth',1,'PlotLineWidth',1,'FontSize',16)

ax.map.YLim = [-30 30];
ax.map.XLim = [-30 30];
ax.map.Position = [.4 .05 .55 .4];
ax.map.YTick = [];
ax.map.XTick = [];
ax.firing_rates.Position(1) = .75;
ax.duty_cycles.Position(1) = .45;

ax.rasters2.Position(1) = .66;
ax.rasters1.Position(3) = .25;
ax.rasters2.Position(3) = .25;

axis(ax.rasters1,'off')
axis(ax.rasters2,'off')

ax.firing_rates.XTickLabel{end-1} = [];



% cleanup
figlib.saveall('Location',display.saveHere)





% what if we PCA all the data
temp = normalize(struct2array(allmetrics));
temp(isnan(temp)) = 0;
P = pca(temp');

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
plot(P(:,1),P(:,2),'k.')

colors = display.colorscheme(alldata.idx);
for i = 1:length(examples)
	x = P(examples(i),1);
	y = P(examples(i),2);
	C = colors.(alldata.idx(examples(i)));
	plot(x,y,'.','MarkerSize',30,'Color',C)
end






figure('outerposition',[300 300 601 901],'PaperUnits','points','PaperSize',[601 901]); hold on
clear ax

% show the ISIs
ax.isis=subplot(3,2,1); hold on
isis = alldata.PD_PD(examples(3),:);
spiketimes = alldata.PD(examples(3),:);
spiketimes = spiketimes - min(spiketimes);
plot(spiketimes,isis','.','Color',colors.PD)
set(gca,'YScale','log','YLim',[.01 1])
ylabel('ISI (s)')
plot([0 20],[.01 .01],'k','LineWidth',3)
ax.isis.XColor = 'w';

ax.isisp = subplot(3,2,3); hold on
ah = area(prctile(isis,[0:10:100]));
ah.FaceColor = colors.PD;
ylabel('ISI (s)')
ax.isip.XColor = 'w';

isis = alldata.LP_LP(examples(3),:);
spiketimes = alldata.LP(examples(3),:);
spiketimes = spiketimes - min(spiketimes);
spiketimes =  spiketimes + 25;
plot(ax.isis,spiketimes,isis','.','Color',colors.LP)


ah = area(ax.isisp,prctile(isis,[0:10:100]));
ah.XData = ah.XData + 12;
ah.FaceColor = colors.LP;


% show the phases
ax.phase = subplot(3,2,2); hold on
isis = PD_LP(examples(3),:);
spiketimes = alldata.PD(examples(3),:);
spiketimes = spiketimes - min(spiketimes);
plot(spiketimes,isis','.','Color',colors.PD)
set(gca,'YLim',[0 1])
ylabel('Phase')

ax.phasep = subplot(3,2,4); hold on
ah = area(prctile(isis,[0:10:100]));
ah.FaceColor = colors.PD;
ylabel('Phase')
set(gca,'YLim',[0 1])


isis = LP_PD(examples(3),:);
spiketimes = alldata.LP(examples(3),:);
spiketimes = spiketimes - min(spiketimes);
spiketimes =  spiketimes + 25;
plot(ax.phase,spiketimes,isis','.','Color',colors.LP)


ah = area(ax.phasep,prctile(isis,[0:10:100]));
ah.FaceColor = colors.LP;
ah.XData = ah.XData + 12;


% show the vectorized data
subplot(3,1,3); hold on
temp = VectorizedData(1:2000:end,:);
temp(size(temp,1)-2:end,:) = NaN;
temp(end,:) = VectorizedData(examples(3),:);
plotlib.imagescnan(temp)
axis off
axis tight


figlib.pretty()

ax.isisp.XColor = 'w';
ax.phase.XColor = 'w';
ax.phasep.XColor = 'w';

ax.isisp.Position(4) = .14;
ax.isis.Position(4) = .14
ax.phase.Position(4) = .14;
ax.phasep.Position(4) = .14;


ax.phase.Position(1) = .6;
ax.phasep.Position(1) = .6;

init()