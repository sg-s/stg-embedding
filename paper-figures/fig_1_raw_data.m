
close all
clearvars -except RawData

% load the raw data
if ~exist('RawData','var')
	load('RawData.mat');
end



% constants
trace_spacing = 2.5;
lp_color = color.aqua('red');
pd_color = color.aqua('indigo');

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
clear ax
for i = 1:2
	ax(i) = subplot(1,2,i); hold on
	axis off
	title(['Preparation ' mat2str(i)],'FontWeight','normal')
end

for i = 1:2
	yoffset = 0;
	for j = 1:4

		LP = RawData(i,j).LP(1:2:5e4);
		PD = RawData(i,j).PD(1:2:5e4);
		time = linspace(0,5,length(LP));
		plot(ax(i),time,LP + yoffset,'Color',lp_color)

		yoffset = yoffset - trace_spacing;
		plot(ax(i),time,PD + yoffset,'Color',pd_color)

		yoffset = yoffset - trace_spacing*2;
		ax(i).XLim = [0 5];

	end

end

% text labels for nerves
th = text(-.05,0,'\itlpn','Parent',ax(1),'Color',lp_color);
th.HorizontalAlignment = 'right';

th = text(-.05,-trace_spacing,'\itpdn','Parent',ax(1),'Color',pd_color);
th.HorizontalAlignment = 'right';

ax_base = axes;
ax_base.Position = [0 0 1 1];
ax_base.XLim = [0 1];
ax_base.YLim = [0 1];
uistack(ax_base,'bottom');

r = rectangle(ax_base,'Position',[.1 .7 .85 .2],'FaceColor',[.9 .9 .9]);
r.EdgeColor = 'none';

% time scale
plot(ax(1),[0 1],[-27 -27],'LineWidth',3,'Color','k')
th = text(0.5,-27.5,'1s','Parent',ax(1),'FontSize',24,'HorizontalAlignment','center');

ax(1).YLim = [-27 3];
ax(2).YLim = [-27 3];


% indicate PD burst period
plot(ax(1),[1.0107 1.643],[-3.5 -3.5],'LineWidth',2,'Color',pd_color)
th = text(1.3268,-4.2,'T_{PD}','HorizontalAlignment','center','FontSize',18,'Color',pd_color,'Parent',ax(1));


% LP, PD annotations
a = annotation('textarrow');
a.Position = [ 0.4426    0.7249   -0.0039    0.0272];
a.String = 'PD';
a.FontSize = 16;

a = annotation('textarrow');
a.Position = [ 0.4573    0.9169   -0.0068   -0.0402];
a.String = 'LP';
a.FontSize = 16;



figlib.pretty('PlotLineWidth',1.5)

th = text(0.1,.92,'Baseline','FontSize',28,'FontWeight','bold','Color',[.85 .85 .85]);
th.Parent = ax_base;