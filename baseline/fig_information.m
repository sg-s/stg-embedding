
% discretize spike trains
if ~exist('discrete','var')
	BinSize = .1; % seconds 
	DataSize = length(alldata.mask);


	discrete.PD = zeros(DataSize,20/BinSize);
	discrete.LP = zeros(DataSize,20/BinSize);

	for i = 1:DataSize
		PD = alldata.PD(i,:);
		LP = alldata.LP(i,:);

		% assuming that the offset has been removed
		LP(isnan(LP)) = [];
		PD(isnan(PD)) = [];


		LP = round(LP/BinSize);
		LP(LP==0) = 1;
		discrete.LP(i,LP) = 1;

		PD = round(PD/BinSize);
		PD(PD==0) = 1;
		discrete.PD(i,PD) = 1;

	end

	discrete.symbols = discrete.PD + discrete.LP*2;
	discrete.words = zeros(DataSize,40);

	basis =  [4^4 4^3 4^2 4 1]';

	for i = 1:DataSize
		temp = reshape(discrete.symbols(i,:),40,5);
		discrete.words(i,:) = temp*basis;
	end

	discrete.words = discrete.words+1;
end

% compute counts for each word
counts = zeros(1024,1);

for i = 1:1024
	counts(i) = sum(discrete.words(:) == i);
end

[sorted_counts,idx] = sort(counts,'descend');
sorted_counts = sorted_counts/sum(sorted_counts);

figure('outerposition',[300 300 1200 1001],'PaperUnits','points','PaperSize',[1200 1001]); hold on


% do for each prep
clear ax
ax(1) = subplot(2,2,1); hold on;
ax(2) = subplot(2,2,2); hold on
unique_exps = unique(alldata.experiment_idx);
all_sorted_counts = NaN(1024,length(unique_exps));
entropies = NaN(length(unique_exps),1);
for i = 1:length(unique_exps)
	counts = zeros(1024,1);

	these_words = discrete.words(alldata.experiment_idx == unique_exps(i),:);
	these_words = these_words(:);

	for j = 1:1024
		counts(j) = sum(these_words == j);
	end

	[sorted_counts,idx] = sort(counts,'descend');
	sorted_counts = sorted_counts/sum(sorted_counts);
	all_sorted_counts(:,i)  = sorted_counts;

	probabilities = counts/sum(counts);
	L = log2(probabilities);
	entropies(i) = -nansum(L.*probabilities);

	plot(ax(1),all_sorted_counts(:,i),'Color',[.8 .8 .8])


end
set(ax(1),'XScale','log','YScale','log')
xlabel(ax(1),'Rank of word')
ylabel(ax(1),'Frequency of occurrence')

plot(ax(1),nanmean(all_sorted_counts,2),'k','LineWidth',2)
ff = fit([1:1024]',nanmean(all_sorted_counts,2),'power1');
plot(ax(1),1:1024,ff(1:1024),'r--')

h = histogram(ax(2),entropies,'NumBins',20,'Normalization','probability');
plotlib.vertline(10)
xlabel('Entropy (bits)')
ax(2).XLim = [0 11];
ax(2).YColor = 'w';




% vocabulary size vs. categories

ax(3) = subplot(2,2,3); hold on

cats = categories(alldata.idx);
vocab_size = zeros(length(cats),1);

for i = 1:length(cats)
	these_words = discrete.words(alldata.idx == cats{i},:);
	these_words = these_words(:);
	vocab_size(i) = length(unique(these_words));
end

[~,idx] = sort(vocab_size);
b = barh(vocab_size(idx));
b.LineStyle = 'none';
ax(3).YTick = 1:length(cats);
ax(3).YTickLabel = cats(idx);
xlabel('Vocabulary size')




% plot rank probabilites grouped by state
entropies = NaN(length(cats),1);
for i = 1:length(cats)
	these_words = discrete.words(alldata.idx == cats{i},:);
	these_words = these_words(:);

	for j = 1:1024
		counts(j) = sum(these_words == j);
	end

	[sorted_counts,idx] = sort(counts,'descend');
	sorted_counts = sorted_counts/sum(sorted_counts);
	all_sorted_counts(:,i)  = sorted_counts;

	probabilities = counts/sum(counts);

	L = log2(probabilities);
	entropies(i) = -nansum(L.*probabilities);


end

[~,idx] = sort(entropies,'descend');


ax(4) = subplot(2,2,4); hold on
[~,idx] = sort(entropies);
b = barh(entropies(idx));
ax(4).YTick = 1:length(cats);
ax(4).YTickLabel = cats(idx);
xlabel('Entropy (bits)')
b.LineStyle = 'none';


figlib.pretty()
ax(2).YColor = 'w';