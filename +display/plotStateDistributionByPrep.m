function [h, P] = plotStateDistributionByPrep(allidx, experiment_idx, OnlyWhen)

assert(length(allidx) == length(experiment_idx),'idx and preps not the same length')
assert(iscategorical(allidx),'Expected idx to be categorical')

unique_exps = unique(experiment_idx);
N = length(unique_exps);
P = zeros(N,length(unique(allidx)));
for i = 1:N
	idx = allidx(experiment_idx == unique_exps(i) & OnlyWhen);
	if isempty(idx)
		continue
	end

	P(i,:) = histcounts(idx);
	P(i,:) = P(i,:)/sum(P(i,:));
end

P(sum(P,2) ==0,:) = [];

h = barh(P,'stacked','LineStyle','none','BarWidth',1);


% get the colors sright
cats = categories(allidx);
colors = display.colorscheme(cats);

for i = 1:length(h)
	h(i).FaceColor = colors(cats{i});
end