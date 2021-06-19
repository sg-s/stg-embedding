% plots a transition matrix in a nice way

function lh = plotTransitionMatrix(J, cats, IsSignificantlySmaller,IsSignificantlyGreater , options)

arguments
	J (:,:) double
	cats cell
	IsSignificantlySmaller (:,:) double = NaN
	IsSignificantlyGreater (:,:) double = NaN
	options.ax = gca
	options.MarkerFaceColor = [.8 .8 .8]
	options.MarkerEdgeColor = [.4 .4 .4]
	options.ShowScale = false
	options.FontSize = 20
	options.ScaleFcn = @(x) 30*x + 10
	options.MarkerSize = 20
	options.ZeroMarkerSize = 10
	options.PlotOrder = {'regular','PD-weak-skipped','LP-weak-skipped','aberrant-spikes','irregular-bursting','irregular','PD-silent-LP-bursting','LP-silent-PD-bursting','PD-silent','LP-silent','sparse-irregular','silent'};
end

% first plot the grid lines using the correct colors
colors = display.colorscheme(cats);

hold(options.ax,'on')
axis(options.ax,'off')


N = size(J,1);

if isnan(IsSignificantlySmaller)
	IsSignificantlySmaller = false(N,N);
end

if isnan(IsSignificantlyGreater)
	IsSignificantlyGreater = false(N,N);
end


for i = 1:N

	this_cat = options.PlotOrder{i};
	this_color = colors.(this_cat);


	% plot horizontal lines
	plot(options.ax,[0 N],[i i],'Color',this_color,'LineWidth',2)
	plot(options.ax,0,i,'>','MarkerSize',options.MarkerSize,'MarkerFaceColor',this_color,'MarkerEdgeColor',this_color)

	% plot vertical lines
	plot(options.ax,[i i],[0 N],'Color',this_color,'LineWidth',2)
	plot(options.ax,i,0,'v','MarkerSize',options.MarkerSize,'MarkerFaceColor',this_color,'MarkerEdgeColor',this_color)
end


% plot discs to indicate weight in J
for i = 1:N
	ii = find(strcmp(options.PlotOrder,cats{i}));
	for j = 1:N
		jj = find(strcmp(options.PlotOrder,cats{j}));
		if J(i,j) == 0
			if IsSignificantlySmaller(i,j)
				plot(options.ax,jj,ii,'d','MarkerSize',options.ZeroMarkerSize,'MarkerFaceColor','w','MarkerEdgeColor','k','LineWidth',3);
			end
			continue
		end

	

		ph = plot(options.ax,jj,ii,'o','MarkerSize',options.ScaleFcn(J(i,j)),'MarkerFaceColor',options.MarkerFaceColor,'MarkerEdgeColor',options.MarkerEdgeColor);
		if IsSignificantlySmaller(i,j)
			ph.MarkerEdgeColor = 'k';
			ph.MarkerFaceColor = [.2 .2 .2];
		end
		if IsSignificantlyGreater(i,j)
			ph.MarkerEdgeColor = 'k';
			ph.LineWidth = 2;
			
		end
	end
end


th = text(options.ax,N/2,-1,'Final state','FontSize',options.FontSize);
th.HorizontalAlignment = 'center';


th = text(options.ax,-1,N/2,'Initial state','FontSize',options.FontSize);
th.HorizontalAlignment = 'center';
th.Rotation = 90;

lh = [];

options.ax.XLim = [0 length(J) + 2.5];
options.ax.YLim = [0 length(J) + .5];
axis(options.ax,'equal')

if ~options.ShowScale
	return
end


scales = [1 .5 .25 .1];
for i = 1:length(scales)
	plot(options.ax,N+1.5,N-i*1.5,'o','MarkerSize',options.ScaleFcn(scales(i)),'MarkerFaceColor',options.MarkerFaceColor,'MarkerEdgeColor',options.MarkerEdgeColor)
	th = text(options.ax,N+2.5,N-i*1.5,mat2str(scales(i)));
	th.FontSize = options.FontSize;
end



