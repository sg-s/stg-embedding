function plotStates(ax, cats, states, time, y)

colors = display.colorscheme(cats);

for j = 1:length(cats)

    yy = y;
    yy(states ~= cats{j}) = NaN;

    if all(isnan(yy))
        continue
    end

    % this effectively plots lines of continuous blocks
    plot(ax,time,yy,'Color',colors(cats{j}),'LineWidth',2.5)

    % now what about single pts? 
    yy1 = circshift(yy,1);
    yy2 = circshift(yy,-1);

    isolated_pts = ~isnan(yy) & isnan(yy1) & isnan(yy2);

    plot(ax,time(isolated_pts),yy(isolated_pts),'.','MarkerSize',10,'Color',colors(cats{j}),'LineStyle','none')


end
