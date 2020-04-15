
% keep the raw data around so we can re-embed if need be
RawData = [cdfs.PD_PD, cdfs.LP_LP, cdfs.LP_LP, cdfs.PD_LP];
RawData(isnan(RawData)) = 0;

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

m.makeUI;
m.handles.ax(1).Position = [0 .3 .6 .6];
axis(m.handles.ax(2),'normal')
m.handles.ax(2).Position = [.05 .05 .9 .1];

m.handles.ax(2).Position(1) = .05;

% cosmetic fixes
box(m.handles.ax(2),'off')
m.handles.ax(2).XColor = 'w';
title(m.handles.ax(2),'')
title(m.handles.ax(1),'')

m.handles.ax(1).XColor = 'w';
m.handles.ax(1).YColor = 'w';


embed_button = uicontrol(m.handles.main_fig,'Units','normalized','Style','pushbutton','String','Embed using uMAP','FontSize',24,'Position',[.75 .4 .2 .1]);

embed_button.Callback = @embed;