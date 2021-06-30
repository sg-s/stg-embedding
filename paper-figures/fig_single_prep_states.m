%%
% this figure takes a single prep, 
% and then plots all the states and the raw data 
% useful for a talk etc

preps = unique(alldata.experiment_idx(alldata.serotonin>5e-7));

prep = preps(1);

cats = categories(alldata.idx);
colors = display.colorscheme(cats);

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(2,1,1); hold on
this = find(alldata.experiment_idx == prep);
xoffset = 0;
for i = 1:length(this)

	PD = alldata.PD(this(i),:) + xoffset;


	neurolib.raster(PD,'deltat',1,'Color',colors.PD,'center',false)
	LP = alldata.LP(this(i),:) + xoffset;
	neurolib.raster(LP,'deltat',1,'Color',colors.LP,'center',false,'yoffset',1)
	xoffset = xoffset + 20;



end

ax = gca;
ax.Position = [.1 .5 .6 .2];
ax.XLim = [2800 3000];
ax.YColor = 'w';

subplot(2,1,2); hold on
ax = gca;
display.plotStates(gca, alldata.idx(this), (1:length(this))*20, 0,'LineWidth',10,'MarkerSize',11)
set(gca,'YLim',[-.1 .1])
ax.Position = [.1 .1 .8 .1];
xlabel('Time (s)')
ax.YColor = 'w';

figlib.pretty