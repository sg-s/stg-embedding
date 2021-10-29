%%
% In this figure I delete random columns from the feature vector and embed
% to see how sensitive the overall map is to individual feature vectors


init()

% frozen random noise
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1984)); 


figure('outerposition',[300 300 701 1111],'PaperUnits','points','PaperSize',[701 1111]); hold on

delete_these = randi(size(VectorizedData,2),6,1);

for i = 1:6
	this_VectorizedData = VectorizedData;
	this_VectorizedData(:,delete_these(i)) = [];

	R = embedding.tsne_data(alldata, PD_LP, LP_PD, this_VectorizedData);

	ax = subplot(3,2,i); hold on

	display.plotEmbedding(ax, R, alldata.idx);


end



figlib.pretty()

figlib.saveall('Location',display.saveHere)

display.trimImage([mfilename '_1.png']);



init()