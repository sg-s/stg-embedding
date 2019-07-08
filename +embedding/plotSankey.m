function [th_feeder, th_end] = plotSankey(J, end_here, labels)


n_layers = 3;
cutoff = .05; % 5%
N = length(labels);

feeder_nodes = plotlib.sankeyMatrix(J, end_here, n_layers, cutoff);

% first plot the final node
th_end = text(0.05, end_here, char(labels(end_here)),'FontWeight','normal');

% now plot the feeder nodes
for i = 1:N
    if ismember(i,feeder_nodes)
        th_feeder(i) = text(-n_layers-.05, (i), char(labels((i))),'FontWeight','normal','HorizontalAlignment','right');
    else
       th_feeder(i) = text(-n_layers-.05, (i), char(labels((i))),'FontWeight','normal','HorizontalAlignment','right','Color',[.7 .7 .7]);
    end
end

axis off