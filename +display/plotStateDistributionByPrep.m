function [h, P] = plotStateDistributionByPrep(alldata,OnlyWhen)

unique_exps = unique(alldata.experiment_idx);
N = length(unique_exps);
P = zeros(N,length(unique(alldata.idx)));
for i = 1:N
	idx = alldata.idx(alldata.experiment_idx == unique_exps(i) & OnlyWhen);
	if isempty(idx)
		continue
	end

	P(i,:) = histcounts(idx);
	P(i,:) = P(i,:)/sum(P(i,:));
end

P(sum(P,2) ==0,:) = [];

h = barh(P,'stacked','LineStyle','none','BarWidth',1);


% get the colors sright
cats = categories(alldata.idx);
colors = display.colorscheme(cats);

for i = 1:length(h)
	h(i).FaceColor = colors(cats{i});
end