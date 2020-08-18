



% this is passed to the interactive labeller so we can look at the spikes
raw_spike_data = [alldata.LP, alldata.PD];





m = clusterlib.manual;
m.idx = embedding.makeCategoricalArray(size(VectorizedData,1));
m.RawData = raw_spike_data;
m.DisplayFcn = @embedding.plotSpikes;
m.labels = categories(m.idx);





% load saved data

load('../annotations/labels.cache','H','idx','-mat')
m.idx = embedding.readAnnotations(idx,H,m.RawData,m.idx);
clearvars H idx midx


fitData = VectorizedData;

% original
u = umap('min_dist',0, 'metric','euclidean','n_neighbors',75,'negative_sample_rate',25);


R = u.fit(fitData);

% R = [metricsLP.Maximum, metricsLP.DominantPeriod];
% R = [DCLP, DCPD];

m.ReducedData = R;
m.RawData = raw_spike_data;


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
m.handles.ax(2).Box = 'on'

embed_button = uicontrol(m.handles.main_fig,'Units','normalized','Style','pushbutton','String','Embed using uMAP','FontSize',24,'Position',[.75 .4 .2 .1]);

embed_button.Callback = @embedding.embed;
