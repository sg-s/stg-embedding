

temp = [alldata.LP, alldata.PD];


if exist('m','var') && isa(m,'clusterlib.manual') && ~all(isundefined(m.idx))
	idx = m.idx;
end


m = clusterlib.manual;

m.RawData = temp;
m.ReducedData = R;
m.DisplayFcn = @plot_LP_PD;



if exist('idx','var') == 1 && all(isundefined(m.idx))
	m.idx = idx;
	m.labels = unique(idx);
end

m.makeUI
m.handles.ax(1).Position = [0 .4 .55 .55];
axis(m.handles.ax(2),'normal')
m.handles.ax(2).Position = [0.02 0.25 .9 .1];

m.handles.ax(2).Position(1) = .05;

% cosmetic fixes
box(m.handles.ax(2),'off')
m.handles.ax(2).XColor = 'w';
title(m.handles.ax(2),'')
title(m.handles.ax(1),'')

m.handles.ax(1).XColor = 'w';
m.handles.ax(1).YColor = 'w';

for i = 1:length(m.handles.ReducedData)
	m.handles.ReducedData(i).MarkerSize = 10;
end