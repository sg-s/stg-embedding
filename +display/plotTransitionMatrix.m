% plots a transition matrix in a nice way

function plotTransitionMatrix(J, cats, options)

arguments
	J (:,:) double
	cats cell
	options.ax = gca
	options.MarkerFaceColor = [.8 .8 .8]
	options.MarkerEdgeColor = [.4 .4 .4]
	options.ShowScale = false
	options.FontSize = 20
end

% first plot the grid lines using the correct colors
colors = display.colorscheme(cats);

hold(options.ax,'on')
axis(options.ax,'off')
axis(options.ax,'square')
set(options.ax,'XLim',[0 length(J)+.5],'YLim',[0 length(J)+.5])

N = size(J,1);
for i = 1:N

	% plot horizontal lines
	plot(options.ax,[0 N],[i i],'Color',colors.(cats{i}),'LineWidth',2)
	plot(options.ax,0,i,'>','MarkerSize',20,'MarkerFaceColor',colors.(cats{i}),'MarkerEdgeColor',colors.(cats{i}))

	% plot vertical lines
	plot(options.ax,[i i],[0 N],'Color',colors.(cats{i}),'LineWidth',2)
	plot(options.ax,i,0,'v','MarkerSize',20,'MarkerFaceColor',colors.(cats{i}),'MarkerEdgeColor',colors.(cats{i}))
end

% plot discs to indicate weight in J
for i = 1:N
	for j = 1:N
		if J(i,j) == 0
			continue
		end
		plot(options.ax,j,i,'o','MarkerSize',10 + J(i,j)*30,'MarkerFaceColor',options.MarkerFaceColor,'MarkerEdgeColor',options.MarkerEdgeColor)
	end
end


th = text(options.ax,N/2,-1,'Final state','FontSize',options.FontSize);
th.HorizontalAlignment = 'center';


th = text(options.ax,-1,N/2,'Initial state','FontSize',options.FontSize);
th.HorizontalAlignment = 'center';
th.Rotation = 90;

if ~options.ShowScale
	return
end

options.ax.XLim(2) = options.ax.XLim(2) + 2;
options.ax.YLim(2) = options.ax.YLim(2) + 2;

scales = [1 .5 .25 .1];
for i = 1:length(scales)
	plot(options.ax,N+1.5,N-i*1.5,'o','MarkerSize',10 + scales(i)*30,'MarkerFaceColor',options.MarkerFaceColor,'MarkerEdgeColor',options.MarkerEdgeColor)
	th = text(options.ax,N+2.5,N-i*1.5,mat2str(scales(i)));
	th.FontSize = options.FontSize;
end

