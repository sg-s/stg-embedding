% plots ISIs from PD and LP together
% as "snakes" going down in time
% useful for visualizing patterns and how they change over time

function snakePlot(data, ax)


LP_color = color.aqua('red');
PD_color = color.aqua('indigo');

if nargin == 1
	figure('outerposition',[300 300 400 700],'PaperUnits','points','PaperSize',[400 700]); hold on
	ax = gca;
	
end

r = rectangle(ax,'Position',[.1 .1 1 1]);

assert(length(ax)==1,'Expected axes handle to be one element long')
assert(isa(ax,'matlab.graphics.axis.Axes'),'Axes handle is not valid')


time_since_decentralization = analysis.timeSinceDecentralization(data);


data.PD(isnan(time_since_decentralization),:) = NaN;
data.LP(isnan(time_since_decentralization),:) = NaN;

PD = sort(data.PD(:));
LP = sort(data.LP(:));

isiPD = [NaN; diff(PD)];
isiLP = [NaN; diff(LP)];

isiPD(isiPD>10) = NaN;
isiLP(isiLP>10) = NaN;

isiLP(isiLP<1e-2) = NaN;


plot(ax,isiPD,PD,'.','Color',PD_color,'MarkerSize',1)
plot(ax,isiLP*100,LP,'.','Color',LP_color,'MarkerSize',1)



ax.XScale = 'log';


decentralized_at = nanmin(data.PD(find(time_since_decentralization>0,1,'first'),:));

try
	r.Position = [.01 decentralized_at 300 1050];
	ax.YLim = [nanmin(data.PD(:)) nanmax(data.PD(:))];
catch
end
r.FaceColor = [.95 .95 .95];
r.LineStyle = 'none';


ax.YDir = 'reverse';
ax.YColor = 'w';
ax.YTick = [];


ax.YLim = [decentralized_at - 300 decentralized_at + 1050];

ax.XLim = [.01 200];

