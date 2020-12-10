% in this figure we vary the perplexity and see what effect that 
% has on the embedding

close all
init()

all_perplexity = linspace(20,180,9);


figure('outerposition',[300 300 1200 1201],'PaperUnits','points','PaperSize',[1200 1201]); hold on
i = 0;

R = embedding.tsne_data(alldata, PD_LP, LP_PD,VectorizedData);
C = ones(length(R),3);
C(:,2) = normalize(R(:,1),'range',[0 1]);
C(:,1) = normalize(R(:,2),'range',[0 1]);

% unpack
idx = alldata.idx;
cats = categories(idx);
colors = display.colorscheme(cats);

for perplexity = all_perplexity
	i = i + 1;
	subplot(3,3,i); hold on
	R = embedding.tsne_data(alldata, PD_LP, LP_PD,VectorizedData, perplexity);

	scatter(R(:,1),R(:,2),10,C,'filled')

	% plot(gca,R(:,1),R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)
	% for j = length(cats):-1:1
	%     plot(gca,R(idx==cats{j},1),R(idx==cats{j},2),'.','Color',colors(cats{j}),'MarkerSize',10)
	    
	% end
	axis square


	drawnow
	axis off
	title(['P = ' mat2str(perplexity)])

end

figlib.pretty()


R = embedding.tsne_data(alldata, PD_LP, LP_PD,VectorizedData);

figlib.saveall('Location',display.saveHere)
init()
