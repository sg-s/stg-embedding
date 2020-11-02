

N = 10000-1;

data = synthetic.makeData;

data = rmfield(data,'burst_period');
data = rmfield(data,'firing_rate');

data.mask = ones(N,1);
data.PD = data.PD';
data.LP = data.LP';


data.PD(end,:) = [];
data.LP(end,:) = [];
data.experiment_idx(end) = [];

data = embedding.DataStore(data);



% sort spikes
data.PD = sort(data.PD,2);
data.LP = sort(data.LP,2);


data = computeISIs(data);

clear LP_PD PD_LP
SynData = data.spikes2percentiles;

SynR = embedding.tsne_data(data,PD_LP, LP_PD, VectorizedData);

cats = unique(data.experiment_idx);


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

for i = 1:length(cats)
	this = data.experiment_idx == cats(i);
	plot(SynR(this,1),SynR(this,2),'.')
end
