% load thing to embed


disp('Varying random seeds, fixed bug saving...')

load('embed_this.mat','eD')



% all_Alpha =      [.7  .7  1   1   .8];
% all_perplexity = [400 300 300 200 500];


% for i = 1:length(all_Alpha)

% 	disp(all_Alpha(i))
% 	disp(all_perplexity(i))


% 	clear R embedding_cost
% 	t = TSNE; 
% 	t.perplexity = all_perplexity(i);
% 	t.Alpha = all_Alpha(i);
% 	t.DistanceMatrix = eD;
% 	t.NIter  = 500;
% 	t.implementation = TSNE.implementation.vandermaaten;
% 	[R, embedding_cost] = t.fit;

% 	% save to explicitly named variable
% 	savename = ['P_' strlib.oval(all_perplexity(i)), '_Alpha_' strlib.oval(all_Alpha(i)) '.mat'];
% 	save(savename,'R','embedding_cost')


% end


% vary random seeds 

all_seeds = 1e3:(1e3+5);
all_perplexity = all_seeds*0 + 500;
all_Alpha = all_seeds*0 + .7;

for i = 1:length(all_seeds)

	disp(all_seeds(i))


	clear R embedding_cost
	t = TSNE; 
	t.perplexity = all_perplexity(i);
	t.Alpha = .7;
	t.RandomSeed = all_seeds(i);
	t.DistanceMatrix = eD;
	t.NIter  = 1e3;
	t.StopLyingIter = 300;
	t.implementation = TSNE.implementation.vandermaaten;
	[R, embedding_cost] = t.fit;

	% save to explicitly named variable
	savename = ['P_' strlib.oval(all_perplexity(i)), '_Seed_' strlib.oval(all_seeds(i)) '.mat'];
	save(savename,'R','embedding_cost')


end
