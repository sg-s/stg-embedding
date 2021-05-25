% in this figure i look at the effect 
% differnet initializations have on the emebdding

close all
init()


rng default

% unpack
idx = alldata.idx;
cats = categories(idx);
colors = display.colorscheme(cats);

figure('outerposition',[300 300 1100 1300],'PaperUnits','points','PaperSize',[1100 1300]); hold on
for i = 6:-1:1
	ax(i) = subplot(3,2,i); hold on
	axis off
end

% random initializations
for i = 1:4
	R0 = randn(length(PD_LP),2);

	R = embedding.tsne_data(alldata, PD_LP, LP_PD,VectorizedData, 100, R0);
	display.plotEmbedding(ax(i),R,idx);

end

% max ISI 
R0 = [nanmax(alldata.LP_LP,[], 2) nanmax(alldata.PD_PD,[],2)];
R = embedding.tsne_data(alldata, PD_LP, LP_PD,VectorizedData, 100, R0);
display.plotEmbedding(ax(5),R,idx);


% mean ISIs
R0 = [nanmean(alldata.LP_LP, 2) nanmean(alldata.PD_PD,2)];
R = embedding.tsne_data(alldata, PD_LP, LP_PD,VectorizedData, 100, R0);
display.plotEmbedding(ax(6),R,idx);


figlib.pretty()


figlib.label('FontSize',28, 'XOffset',0)

figlib.saveall('Location',display.saveHere)
init()
