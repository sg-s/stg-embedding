% makes a figure showing where the baseline data is.
% the point is to show that baseline data is surprisingly variable

subidx = embedding.watersegment(R);
basedata = filter(alldata,sourcedata.DataFilter.Baseline);
[basedata.idx, base_hashes] = basedata.getLabelsFromCache;
is_baseline = ismember(alldata_hashes,base_hashes);


figure('outerposition',[300 300 1800 901],'PaperUnits','points','PaperSize',[1800 901]); hold on
clear ax

% show baseline occupancy
ax(1) = subplot(1,2,1); hold on
fh = display.plotSubClusters(gca,alldata.idx,R,.1,subidx);
cats = categories(alldata.idx);
colors = display.colorscheme(alldata.idx);

for i = 1:length(cats)
	plot(R(alldata.idx == cats(i) & is_baseline,1),R(alldata.idx == cats(i) & is_baseline,2),'.','Color',colors(cats{i}),'MarkerSize',5)
end

axis(ax(1),'off')
axis square


ax(2) = subplot(2,2,2); hold on
X = histcounts(basedata.idx);
X = X/sum(X);
[X,sort_order] = sort(X);
for i = 1:length(X)
	bh(i) = barh(i,X(i));
end
set(gca,'XScale','log','YTick',[1:length(X)],'YTickLabel',sorted_cats)
sorted_cats = cats(sort_order);
for i = 1:length(sorted_cats)
	bh(i).FaceColor = colors.(sorted_cats{i});
	bh(i).EdgeAlpha = 0;
end
xlabel('Probability of observing state')


% see how broadly distributed the states are
n_preps_in_state = zeros(length(cats),1);
unique_preps = unique(basedata.experiment_idx);
npreps = 0;
for i = 1:length(unique_preps)
	if isundefined(unique_preps(i))
		continue
	end
	this_idx = basedata.idx(basedata.experiment_idx == unique_preps(i));
	temp = histcounts(this_idx);
	temp(temp>1) = 1;
	n_preps_in_state = n_preps_in_state + temp';
	npreps = npreps+1;
end
n_preps_in_state = n_preps_in_state/npreps;

n_preps_in_state = n_preps_in_state(sort_order);
ax(4) = subplot(2,2,4); hold on
for i = 1:length(n_preps_in_state)
	bh(i) = barh(i,n_preps_in_state(i));
end
for i = 1:length(sorted_cats)
	bh(i).FaceColor = colors.(sorted_cats{i});
	bh(i).EdgeAlpha = 0;
end
set(gca,'XScale','log','YTick',[1:length(X)],'YTickLabel',sorted_cats)
xlabel('Fraction of preparations with state')

figlib.pretty('FontSize',15)

ax(2).Position = [.6 .62 .33 .35];
ax(4).Position = [.6 .1 .33 .35];
