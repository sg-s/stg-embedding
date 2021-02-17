% normal data


close all
init

states = {
	'e06903495ff4011fc4003ea799ed4026',
	'bdf3ee7e2c27802014e6444104df8230',
	'b90284a5753b635a07b9a023496a7912',
	'f6e66cb880f412ceed12d17dd6089e6e', % irregular bursting
	'8e28b7f2fb33ea1fe21ddfc084750c81', % LP-weak skipped
	'345b893c47abb0b7243b4d5fb3f419fd' % LP silent
};


% e8128afb66562e19e39807c665951f36


figure('outerposition',[300 300 1344 1222],'PaperUnits','points','PaperSize',[1344 1222]); hold on

clear ax
ax.cartoon = subplot(4,4,1); hold on
ax.states = subplot(4,4,2:4); hold on
ax.isis = subplot(4,4,5); hold on
ax.phases = subplot(4,4,6); hold on
ax.map = subplot(2,2,4); hold on
ax.prctiles(1) = subplot(4,4,9); hold on
ax.prctiles(2) = subplot(4,4,10); hold on
ax.dataframe = subplot(4,2,7); hold on


colors = display.colorscheme(alldata.idx);

% show rasters of examples
for i = 1:length(states)
	idx = find(strcmp(hashes.alldata,states{i}));

	PD = alldata.PD(idx,:);
	LP = alldata.LP(idx,:);
	a = nanmin([PD(:); LP(:)]);
	PD = PD - a;
	LP = LP - a;

	neurolib.raster(ax.states,PD,'deltat',1,'yoffset',i+.5,'Color',colors.PD,'center',false,'RowHeight',.3)
	neurolib.raster(ax.states,LP,'deltat',1,'yoffset',i + .8,'Color',colors.LP,'center',false,'RowHeight',.3)
end

set(ax.states,'YLim',[.5 i+.8],'XLim',[-.1 10])
ax.states.YDir = 'reverse';


show_this = find(strcmp(hashes.alldata,states{2}));

% show the ISIs



isis = alldata.PD_PD(show_this,:);
spiketimes = alldata.PD(show_this,:);
spiketimes = spiketimes - min(spiketimes);
plot(ax.isis,spiketimes,isis','.','Color',colors.PD)
set(ax.isis,'YScale','log','YLim',[.001 1])
ylabel(ax.isis,'ISI (s)')
plot(ax.isis,[10 20],[.001 .001],'k','LineWidth',3)
ax.isis.XColor = 'w';


ah = area(ax.prctiles(1),prctile(isis,[0:10:100]));
ah.FaceColor = colors.PD;
ylabel(ax.prctiles(1),'ISI (s)')
ax.prctiles(1).XColor = 'w';


isis = alldata.LP_LP(show_this,:);
spiketimes = alldata.LP(show_this,:);
spiketimes = spiketimes - min(spiketimes);
spiketimes =  spiketimes + 25;
plot(ax.isis,spiketimes,isis','.','Color',colors.LP)



ah = area(ax.prctiles(1),prctile(isis,[0:10:100]));
ah.XData = ah.XData + 12;
ah.FaceColor = colors.LP;




% show the phases
isis = PD_LP(show_this,:);
spiketimes = alldata.PD(show_this,:);
spiketimes = spiketimes - min(spiketimes);
plot(ax.phases,spiketimes,isis','.','Color',colors.PD)
set(ax.phases,'YLim',[0 1])
ylabel(ax.phases,'Spike phase')



ah = area(ax.prctiles(2),prctile(isis,[0:10:100]));
ah.FaceColor = colors.PD;
ylabel(ax.prctiles(2),'Spike phase')
set(ax.prctiles(2),'YLim',[0 1])


isis = LP_PD(show_this,:);
spiketimes = alldata.LP(show_this,:);
spiketimes = spiketimes - min(spiketimes);
spiketimes =  spiketimes + 25;
plot(ax.phases,spiketimes,isis','.','Color',colors.LP)


ah = area(ax.prctiles(2),prctile(isis,[0:10:100]));
ah.FaceColor = colors.LP;
ah.XData = ah.XData + 12;



% show the vectorized data
h = bar(ax.dataframe,1:11,VectorizedData(show_this,1:11));
h.FaceColor = colors.PD;
h.LineStyle = 'none';

h = bar(ax.dataframe,13:23,VectorizedData(show_this,12:22));
h.FaceColor = colors.LP;
h.LineStyle = 'none';

h = bar(ax.dataframe,25:35,VectorizedData(show_this,23:33));
h.FaceColor = colors.PD;
h.LineStyle = 'none';

h = bar(ax.dataframe,37:47,VectorizedData(show_this,34:44));
h.FaceColor = colors.LP;
h.LineStyle = 'none';

h = bar(ax.dataframe,50:57,VectorizedData(show_this,45:end));
h.FaceColor = [.5 .5 .5];
h.LineStyle = 'none';

ylabel(ax.dataframe,'z-score')


plot(ax.map,R(:,1),R(:,2),'.','Color',[.5 .5 .5])
xlabel(ax.map,'t-SNE 1')
ylabel(ax.map,'t-SNE 2')
axis(ax.map,'square')



figlib.pretty('PlotLineWidth',1.5)


ax.map.XLim = [-30 30];
ax.map.YLim = [-30 30];
ax.states.XColor = 'w';

ax.prctiles(2).XColor = 'w';


ax.dataframe.YMinorGrid = 'on';
ax.dataframe.XColor = 'w';
ax.phases.XColor = 'w';

ax.states.Position = [.33 .74 .57 .2];
ax.isis.Position = [.11 .55 .13 .11];
ax.phases.Position = [.32 .55 .13 .11];
ax.prctiles(1).Position = [.11 .35 .13 .11];
ax.prctiles(2).Position = [.32 .35 .13 .11];
ax.map.Position = [.5 .15 .5 .5];
ax.dataframe.Position = [.11 .14 .35 .15];
ax.cartoon.Position = [.06 .75 .18 .18];


figlib.showImageInAxes(ax.cartoon,imread('circuit.png'))


% create annotations

arrow_color = [ 0.0078    0.7490    0.2039];

axes(ax.map)
clear a
for i = 1:length(states)
	idx = find(strcmp(hashes.alldata,states{i}));
	x = R(idx,1);
	y = R(idx,2);
	plot(x,y,'.','MarkerSize',10,'Color',[ 0.0078    0.7490    0.2039]);
	[theta,rho] = cart2pol(x,y);
	[x2,y2]=pol2cart(theta,rho+5);
	x = [x; x2];
	y = [y; y2];
	
	plot(x,y,'Color',[ 0.0078    0.7490    0.2039]);
	th = text(x(2),y(2),mat2str(i),'FontSize',18);

	if i == 4 | i == 6
		th.HorizontalAlignment = 'right';
	end
end

th.VerticalAlignment = 'bottom';

axlib.label(ax.cartoon,'a','FontSize',28,'XOffset',-.01);
axlib.label(ax.states,'b','FontSize',28,'XOffset',-.01)
axlib.label(ax.isis,'c','FontSize',28,'XOffset',-.01)
axlib.label(ax.prctiles(1),'d','FontSize',28,'XOffset',-.01)
axlib.label(ax.dataframe,'e','FontSize',28,'XOffset',-.01)
axlib.label(ax.map,'f','FontSize',28,'XOffset',-.01)

figlib.saveall('Location',display.saveHere)

% clean up workspace
init()