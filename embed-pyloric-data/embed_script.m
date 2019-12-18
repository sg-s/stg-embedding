% load thing to embed

load('embed_this.mat','eD')


perplexity_range = 200:100:500;
Alpha_range = .5;

all_Alpha = NaN(length(perplexity_range)*length(Alpha_range),1);
all_perplexity = NaN(length(perplexity_range)*length(Alpha_range),1);


idx = 1;
for i = 1:length(Alpha_range)
	for j = length(perplexity_range):-1:1
		all_Alpha(idx) = Alpha_range(i);
		all_perplexity(idx) = perplexity_range(j);
		idx = idx +1;
	end
end


for i = 1:length(all_Alpha)

	disp(all_Alpha(i))
	disp(all_perplexity(i))


	t = TSNE; 
	t.perplexity = all_perplexity(i);
	t.Alpha = all_Alpha(i);
	t.DistanceMatrix = eD;
	t.NIter  = 1e3;
	t.implementation = TSNE.implementation.vandermaaten;
	R = t.fit;


end
