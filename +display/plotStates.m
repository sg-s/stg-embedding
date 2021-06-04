% plots states in a line, useful for making neural ethogram
% plots

function [lines, points] = plotStates(ax, states, time, YOffset, options)

arguments
    ax (1,1) matlab.graphics.axis.Axes
    states (:,1) categorical
    time (:,1) double
    YOffset (1,1) double 
    options.LineWidth = 2
    options.MarkerSize = 15
end


cats = categories(states);
colors = display.colorscheme(cats);




for j = length(cats):-1:1

    y = time*0 + YOffset;
    y(states ~= cats{j}) = NaN;

    if all(isnan(y))
        continue
    end

    % this effectively plots lines of continuous blocks
    
    lines(j) = plot(ax,time(:),y(:),'Color',colors(cats{j}),'LineWidth',options.LineWidth);

    % now what about single pts? 
    y1 = circshift(y,1);
    y2 = circshift(y,-1);

    isolated_pts = ~isnan(y) & isnan(y1) & isnan(y2);

    if any(isolated_pts)
        points(j) = plot(ax,time(isolated_pts),y(isolated_pts),'.','MarkerSize',options.MarkerSize,'Color',colors(cats{j}),'LineStyle','none');
    end


end

C = display.colorscheme(states);
cats = categories(states);
CC = zeros(length(cats),3);

for i = 1:length(cats)
    CC(i,:) = C.(cats{i});
end

