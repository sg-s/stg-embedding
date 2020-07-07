



% this is passed to the interactive labeller so we can look at the spikes
raw_spike_data = [alldata.LP, alldata.PD];





m = clusterlib.manual;
m.idx = embedding.makeCategoricalArray(size(VectorisedPercentiles,1));
m.RawData = raw_spike_data;
m.DisplayFcn = @embedding.plotSpikes;
m.labels = categories(m.idx);





% load saved data
load('../annotations/labels.cache','H','idx','-mat')
for i = 1:length(m.idx)
	corelib.textbar(i,length(m.idx))
	this_hash = hashlib.md5hash(m.RawData(i,:));
	loc = find(strcmp(this_hash,H));
	if ~isempty(loc)
		loc = loc(1);
		m.idx(i) = idx(loc);
	end
end
clearvars H idx


fitData = VectorisedPercentiles;

% this purges identified states
% rm_this = ~isundefined(m.idx);
% m.idx(rm_this) = [];
% fitData(rm_this,:) = [];
% raw_spike_data(rm_this,:) = [];



u = umap('min_dist',0, 'metric','euclidean','n_neighbors',50,'negative_sample_rate',15);
R = u.fit(fitData);
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


embed_button = uicontrol(m.handles.main_fig,'Units','normalized','Style','pushbutton','String','Embed using uMAP','FontSize',24,'Position',[.75 .4 .2 .1]);

embed_button.Callback = @embedding.embed;
