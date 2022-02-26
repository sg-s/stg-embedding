

[coeff,score,latent,tsquared,explained,mu] = pca(VectorizedData');

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(1,2,1); hold on
idx = kmeans(coeff(:,[1:10]),10);
display.plotEmbedding(gca,coeff(:,[1:2]),idx);
xlabel('PCA-1')
ylabel('PCA-2')

subplot(1,2,2); hold on
display.plotEmbedding(gca,R,idx);
xlabel('t-SNE-1')
ylabel('t-SNE-2')

figlib.pretty()

figlib.label('FontSize',28,'XOffset',-.02)


figlib.saveall('Location',display.saveHere,'Format','png')

