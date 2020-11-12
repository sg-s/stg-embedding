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

PD = data.PD;
LP = data.LP;

offsets = nanmin([PD LP],[],2);


isiPD = diff(PD,[],2);
isiLP = diff(LP,[],2);

isiPD(isiPD>10) = NaN;
isiLP(isiLP>10) = NaN;

isiLP(isiLP<1e-2) = NaN;



% we need to handle things differnetly based on whether
% data is decentralized or not
% if data is decentralized, try to show continugous blocks
% around decentralization point
% if not, fuck time and just show them sequentially 


decentralized_at = find(time_since_decentralization>0,1,'first');




if isempty(decentralized_at)
	% not decentralized

	Y_PD = repmat((1:size(isiLP,1))',1,999)*20;
	Y_LP = repmat((1:size(isiLP,1))',1,999)*20;

	% now correct each row of Y with the spiketimes
	% for greater granularity
	for i = 1:size(Y_PD,1)
		Y_PD(i,:) = Y_PD(i,:)+PD(i,1:end-1)-offsets(i);
		Y_LP(i,:) = Y_LP(i,:)+LP(i,1:end-1)-offsets(i);
	end

	

	plot(ax,isiPD,Y_PD,'.','Color',PD_color,'MarkerSize',1)
	plot(ax,isiLP*1000,Y_LP,'.','Color',LP_color,'MarkerSize',1)


else


	keyboard

	r.Position = [.01 decentralized_at 300 1050];
	ax.YLim = [decentralized_at - 300 decentralized_at + 1050];


end




ax.XScale = 'log';
ax.YDir = 'reverse';
ax.YColor = 'w';
ax.YTick = [];


ax.XLim = [.01 5000];
ax.XTick = [1e-2 1];
ax.XTickLabel = {'10^{-2}','1'};

YMax = nanmax([Y_PD(:); Y_LP(:)]) + 100;

ax.YLim(2) = YMax;

r.FaceColor = [.95 .95 .95];
r.LineStyle = 'none';




plot(ax,[5 1e5],[ax.YLim(2) ax.YLim(2)],'LineWidth',10,'Color','w')