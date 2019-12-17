% load thing to embed

load('embed_this.mat')


all_perplexity = [30:30:120];
all_Alpha = [.5:.1:1];


for i = 1:length(all_Alpha)

	for j = 1:length(all_perplexity)

		t = TSNE; 
		t.perplexity = all_perplexity(j);
		t.Alpha = all_Alpha(i);
		t.DistanceMatrix = eD;
		t.NIter  = 1e3;
		t.implementation = TSNE.implementation.vandermaaten;
		R = t.fit;

	end

end

