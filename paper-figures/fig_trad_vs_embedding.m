

close all

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
examples = {'f339a5d3558c2d54788d992479d1cd6b',
    'e972805d6eff58fdd7f8d5c7f8b5e201',
    'cd7cf44fe2c0c205b6328210a7fb073a',
    '8e015606a5820f2ee825c8897da39e5a',
    'f26eb2ff90ec64ed641cb2c92f5ab8ab',
    'dcf177efe29c79ef38eccfac23e7bc1f'};

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
sh = scatter(R(:,1),R(:,2),2);
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

ax.map.XLim = [-30 40];
ax.map.YLim = [-20 35];
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