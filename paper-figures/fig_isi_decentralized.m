% makes a figure showing ISIs of different preps as they are decentralized
% to visualize what happens when preps are decentralized 


init()
close all

figure('outerposition',[300 300 1400 999],'PaperUnits','points','PaperSize',[1400 999]); hold on

clear ax
for i = 1:18
	ax(i) = subplot(3,6,i); hold on
end

idx = 1;

% unchanged
show_this = {'876_047'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end




% slows down, keeps bursting
show_this = {'862_133','862_104','862_114'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end

% slows, then stops
show_this = {'876_062','862_152'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end



% LP craps out
show_this = {'862_101','862_075','862_145'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end




% irregular, interrupted bursting
show_this = {'862_149','879_046'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end



% bouting/oscillations
show_this = {'862_128'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end


% tonic
show_this = {'876_027','876_021'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end





% both stop
show_this = {'140_087'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end


% stop, then restart
show_this = {'140_086'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end


% fluctuates, keeps bursting
show_this = {'876_016','862_129'};

for i = 1:length(show_this)
	showdata = alldata.purge(alldata.experiment_idx ~= show_this{i});
	showdata.snakePlot(ax(idx));
	idx = idx+1;
end



figlib.pretty('LineWidth',1.5,'AxesColor','w')

for i = 1:length(ax)
	ax(i).Position(3) = .1;
	ax(i).Position(4) = .25;
end

ax(1).XColor = [.5 .5 .5];
ax(1).XTick = [.01 1];
ax(1).XMinorTick = 'on';
ax(1).XTickLabel = {'.01','1'};

ph = plot(ax(1),[1.05 1e3],[ax(1).YLim(2) ax(1).YLim(2)],'LineWidth',10,'Color','w');

plot(ax(1),[.01 .01],[ax(1).YLim(2)-1000 ax(1).YLim(2)-800],'LineWidth',3,'Color',[.5 .5 .5]);

figlib.label('XOffset',-.015,'YOffset',-.04,'Color',[.3 .3 .3])

t = text(ax(1),.01,ax(1).YLim(2)-900,'200s ','HorizontalAlignment','right','FontSize',15,'Color',[.5 .5 .5]);


ax(1).XLim(1) = .00901;


for i = 2:length(ax)
	ax(i).XColor ='w';
end

% cleanup
figlib.saveall('Location',display.saveHere)

init()