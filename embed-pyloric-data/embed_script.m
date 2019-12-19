% load thing to embed


load('embed_this.mat','eD')



all_Alpha =      [.7  .7  1   1   .8];
all_perplexity = [400 300 300 200 500];


for i = 1:length(all_Alpha)

	disp(all_Alpha(i))
	disp(all_perplexity(i))


	clear R embedding_cost
	t = TSNE; 
	t.perplexity = all_perplexity(i);
	t.Alpha = all_Alpha(i);
	t.DistanceMatrix = eD;
	t.NIter  = 500;
	t.implementation = TSNE.implementation.vandermaaten;
	[R, embedding_cost] = t.fit;

	% save to explicitly named variable
	savename = ['P_' strlib.oval(all_perplexity(i)), '_Alpha_' strlib.oval(all_Alpha(i)) '.mat'];
	save(savename,'R','embedding_cost')


end
