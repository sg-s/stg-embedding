



% this is passed to the interactive labeller so we can look at the spikes
raw_spike_data = [alldata.LP, alldata.PD];

if 	exist('u','var') && isa(u,'umap')
else
	u = umap('min_dist',0, 'metric','euclidean','n_neighbors',50,'negative_sample_rate',15);
	R = u.fit(VectorisedPercentiles);
end

if exist('m','var') && isa(m,'clusterlib.manual') 
else
	m = clusterlib.manual;
end


if all(isundefined(m.idx))
	% attempt to find the "normal" data in this automatically

	disp('Guessing normal states...')

	clear LP_metrics PD_metrics


	normal = false(size(alldata.LP,1),1);

	for i = size(alldata.LP,1):-1:1
		LP_metrics(i) = xtools.spiketimes2BurstMetrics(alldata.LP(i,:),'MaxISI',.25);
		PD_metrics(i) = xtools.spiketimes2BurstMetrics(alldata.PD(i,:),'MaxISI',.25);
	end

	LP_metrics = structlib.scalarify(LP_metrics);
	PD_metrics = structlib.scalarify(PD_metrics);
	
	LPok = LP_metrics.burst_period_std < .1 & LP_metrics.burst_period_mean < 2 & LP_metrics.duty_cycle_std < .1 & LP_metrics.duty_cycle_mean > .1 & LP_metrics.duty_cycle_mean < .3 & LP_metrics.n_spikes_per_burst_mean > 2 & LP_metrics.n_spikes_per_burst_mean < 10;

	PDok = PD_metrics.burst_period_std < .1 & PD_metrics.burst_period_mean < 2 & PD_metrics.duty_cycle_std < .1 & PD_metrics.duty_cycle_mean > .1 & PD_metrics.duty_cycle_mean < .3 & PD_metrics.n_spikes_per_burst_mean > 2 & PD_metrics.n_spikes_per_burst_mean < 10;

	normal = PDok & LPok;

	m.idx = embedding.makeCategoricalArray(length(normal));
	m.idx(normal) = 'normal';

	disp([mat2str(sum(normal)) ' points labelled normal'])
	

end


m.RawData = raw_spike_data;
m.ReducedData = R;
m.DisplayFcn = @embedding.plotSpikes;
m.labels = categories(m.idx);





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
