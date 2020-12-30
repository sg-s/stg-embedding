% makes a figure showing where the decentralized data is.
% the point is to show that baseline data is surprisingly variable


init()
close all

cats = categories(alldata.idx);
colors = display.colorscheme(alldata.idx);




dec_hashes = hashes.decdata(decdata.decentralized);
is_decentralized = ismember(hashes.alldata,dec_hashes) & alldata.decentralized;

figure('outerposition',[300 300 1800 901],'PaperUnits','points','PaperSize',[1800 901]); hold on
clear ax

% show baseline occupancy
ax(1) = subplot(1,2,1); hold on
display.plotBackgroundLabels(ax(1),alldata, R)

for i = 1:length(cats)
	plot(R(alldata.idx == cats(i) & is_decentralized,1),R(alldata.idx == cats(i) & is_decentralized,2),'.','Color',colors(cats{i}),'MarkerSize',5)
end

axis(ax(1),'off')
ax(1).XLim = [-31 31];
ax(1).YLim = [-31 31];
axis square




% measure variation in map before and after decentralization
unique_preps = unique(decdata.experiment_idx);
S_before = NaN(length(unique_preps),1);
S_after = NaN(length(unique_preps),1);

Distance = @(RR) mean(sqrt(sum((RR(2:end,:) - RR(1:end-1,:)).^2,2)));

Null_differences = S_before;
N = 1;

for i = 1:length(unique_preps)
	this1 = alldata.experiment_idx == unique_preps(i) & alldata.decentralized == false;
	RR = R(this1,:);
	S_before(i) = Distance(RR);

	this2 = alldata.experiment_idx == unique_preps(i) & alldata.decentralized == true;
	RR = R(this2,:);
	S_after(i) = Distance(RR);

end




ax(2) = subplot(2,4,3); hold on

c = lines;

scatter(S_before,S_after,24,'MarkerFaceColor',c(4,:),'MarkerEdgeColor',c(4,:),'MarkerFaceAlpha',.5)
plotlib.drawDiag(ax(2),'k--');
ax(2).XLim = [0 12];
ax(2).YLim = [0 12];
xlabel('Mean distance before decentralization (a.u.)')
ylabel('Mean distance after decentralization (a.u.)')


[~,handles] = statlib.pairedPermutationTest(S_before,S_after,1e4,true);


subplot(2,4,4); hold on
display.stateLegend(gca,cats);


ax(4) = subplot(2,2,4); hold on	
ax_mon = display.pairedMondrian(ax(4),decdata,~decdata.decentralized, decdata.decentralized,'baseline','decentralized');


figlib.pretty('FontSize',15)


% ax(2).Position = [.6 .62 .33 .35];

h = axlib.label(ax(1),'a','FontSize',28,'XOffset',0,'YOffset',-.02);
h = axlib.label(ax(2),'b','FontSize',28,'XOffset',-.04,'YOffset',-.02);
h = axlib.label(ax(4),'c','FontSize',28,'XOffset',-.03,'YOffset',-.02);
h = axlib.label(ax_mon(3),'d','FontSize',28,'XOffset',-.02,'YOffset',-.02);



figlib.saveall('Location',display.saveHere)
init()