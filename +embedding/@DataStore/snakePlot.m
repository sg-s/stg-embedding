function snakePlot(data, ax)

if nargin == 1
	figure('outerposition',[300 300 400 700],'PaperUnits','points','PaperSize',[400 700]); hold on
	ax = gca;
	
end

r = rectangle(ax,'Position',[.1 .1 1 1]);

assert(length(ax)==1,'Expected axes handle to be one element long')
assert(isa(ax,'matlab.graphics.axis.Axes'),'Axes handle is not valid')

% purge all discontinuous data

last_reset = find(data.time_offset == 0,1,'last');
if last_reset ~= 1
	rm_this = logical(data.mask*0);
	rm_this(1:last_reset-1) = true;
	data = data.purge(rm_this);
end

assert(length(find(data.time_offset == 0))==1,'Data has a break')


PD = sort(data.PD(:));
LP = sort(data.LP(:));

isiPD = [NaN; diff(PD)];
isiLP = [NaN; diff(LP)];

isiPD(isiPD>10) = NaN;
isiLP(isiLP>10) = NaN;



isiLP(isiLP<1e-2) = NaN;


% mark when it is decentralized
temp = [data.PD(:,find(data.decentralized,1,'first'):end); data.LP(:,find(data.decentralized,1,'first'):end)];

if ~isempty(temp)
	PD(PD>nanmin(temp(:))+1000) = NaN;
	LP(LP>nanmin(temp(:))+1000) = NaN;
end

plot(ax,isiPD,PD,'.','Color',color.onehalf('blue'),'MarkerSize',1)
plot(ax,isiLP*100,LP,'.','Color',color.onehalf('orange'),'MarkerSize',1)



ax.XScale = 'log';


try
	r.Position = [.01 nanmin(temp(:)) 300 1000];
	ax.YLim = [nanmin(data.PD(:)) nanmax(data.PD(:))];
catch
end
r.FaceColor = [.95 .95 .95];
r.LineStyle = 'none';


ax.YDir = 'reverse';
ax.YColor = 'w';
ax.YTick = [];

if ~isempty(temp)
	ax.YLim = [nanmin(temp(:)) - 300 nanmin(temp(:)) + 1050];
end
ax.XLim = [.01 200];

end