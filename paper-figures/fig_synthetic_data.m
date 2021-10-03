
addpath('../')

N = 10000-1;


if ~exist('data','var')
	data = synthetic.makeData;

	data = rmfield(data,'burst_period');
	data = rmfield(data,'firing_rate');

	data.mask = ones(N,1);
	data.PD = data.PD';
	data.LP = data.LP';


	data.PD(end,:) = [];
	data.LP(end,:) = [];
	data.experiment_idx(end) = [];

	% sort spikes
	data.PD = sort(data.PD,2);
	data.LP = sort(data.LP,2);


	data.LP_channel = repmat(categorical("LP"),N,1);
	data.PD_channel = repmat(categorical("PD"),N,1);


	data = embedding.DataStore(data);

	data = computeISIs(data);

	clear LP_PD PD_LP
	SynData = data.spikes2percentiles;

end

SynR = embedding.tsne_data(data,PD_LP, LP_PD, SynData);

cats = unique(data.experiment_idx);


figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
colors = colormaps.dcol(length(cats));
for i = 1:length(cats)
	this = data.experiment_idx == cats(i);
	plot(SynR(this,1),SynR(this,2),'.','Color',colors(i,:))
	l(i) = plot(NaN,NaN,'.','MarkerSize',40,'Color',colors(i,:));
end
xlabel('t-SNE 1')
ylabel('t-SNE 2')
legend(l,cats,'Location','eastoutside')
axis square
set(gca,'XLim',[-65 65],'YLim',[-65 65])
figlib.pretty

figlib.saveall('Location',display.saveHere)
