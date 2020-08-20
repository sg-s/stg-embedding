% makes a figure showing where the baseline data is.
% the point is to show that baseline data is surprisingly variable


init
close all

subidx = embedding.watersegment(R);


dec_hashes = hashes.decdata(decdata.decentralized);
is_decentralized = ismember(hashes.alldata,dec_hashes);

figure('outerposition',[300 300 1800 901],'PaperUnits','points','PaperSize',[1800 901]); hold on
clear ax

% show baseline occupancy
ax(1) = subplot(1,2,1); hold on
fh = display.plotSubClusters(gca,alldata.idx,R,.1,subidx);
cats = categories(alldata.idx);
colors = display.colorscheme(alldata.idx);

for i = 1:length(cats)
	plot(R(alldata.idx == cats(i) & is_decentralized,1),R(alldata.idx == cats(i) & is_decentralized,2),'.','Color',colors(cats{i}),'MarkerSize',5)
end

axis(ax(1),'off')
axis square


ax(2) = subplot(2,2,2); hold on
X = histcounts(decdata.idx(decdata.decentralized));
X = X/sum(X);
[X,sort_order] = sort(X);
for i = 1:length(X)
	bh(i) = barh(i,X(i));
end

sorted_cats = cats(sort_order);
set(gca,'XScale','log','YTick',[1:length(X)],'YTickLabel',sorted_cats)

for i = 1:length(sorted_cats)
	bh(i).FaceColor = colors.(sorted_cats{i});
	bh(i).EdgeAlpha = 0;
end
xlabel('Probability of observing state')



% compute state probabilities when decentralized and when not
clear P
P.decentralized = decdata.probState(decdata.decentralized);
P.intact = decdata.probState(~decdata.decentralized);




ax(3) = subplot(2,2,4); hold on	
display.pairedMondrian(ax(3),decdata,~decdata.decentralized, decdata.decentralized,'baseline','decentralized');



figlib.pretty('FontSize',15)


ax(2).Position = [.6 .62 .33 .35];



figlib.saveall
init()