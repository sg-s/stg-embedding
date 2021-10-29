% in this figure we vary the perplexity and see what effect that 
% has on the embedding

close all
init()

all_perplexity = ceil(linspace(2,180,12));


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
	subplot(4,3,i); hold on
	R = embedding.tsne_data(alldata, PD_LP, LP_PD, VectorizedData, perplexity);

	scatter(R(:,1),R(:,2),10,C,'filled')

	axis square


	drawnow
	axis off
	title(['P = ' mat2str(perplexity)])

	if perplexity == 100
		axis on
		set(gca,'XColor','r','YColor','r','YTick',[],'XTick',[])
		box on
	end 

end

figlib.pretty()


R = embedding.tsne_data(alldata, PD_LP, LP_PD,VectorizedData);

figlib.saveall('Location',display.saveHere)
init()
