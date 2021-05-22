% plots states in a line, useful for making neural ethogram
% plots

function plotStates(ax, states, time, YOffset)

arguments
    ax (1,1) matlab.graphics.axis.Axes
    states (:,1) categorical
    time (:,1) double
    YOffset (1,1) double 
end


cats = categories(states);
colors = display.colorscheme(cats);

for j = 1:length(cats)

    y = time*0 + YOffset;
    y(states ~= cats{j}) = NaN;

    if all(isnan(y))
        continue
    end

    % this effectively plots lines of continuous blocks
    
    plot(ax,time(:),y(:),'Color',colors(cats{j}),'LineWidth',2)

    % now what about single pts? 
    y1 = circshift(y,1);
    y2 = circshift(y,-1);

    isolated_pts = ~isnan(y) & isnan(y1) & isnan(y2);

    plot(ax,time(isolated_pts),y(isolated_pts),'.','MarkerSize',15,'Color',colors(cats{j}),'LineStyle','none')


end
