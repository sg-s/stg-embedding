% plot maps prep by prep


[N,preps]=histcounts(basedata.experiment_idx);
[N,idx] = sort(N,'descend');
preps = preps(idx);

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

for i = 1:9

	subplot(3,3,i); hold on

	clear PD_LP LP_PD
	prep = basedata.slice(basedata.experiment_idx==preps{i});
	VectorizedData = prep.spikes2percentiles;

	u = umap;
	u.n_neighbors = 50;
	u.negative_sample_rate = 20;
	R = u.fit(VectorizedData);

	plot(R(:,1),R(:,2),'.')


end