% makes a figure showing where the baseline data is.
% the point is to show that baseline data is surprisingly variable


init()
close all

cats = categories(alldata.idx);
colors = display.colorscheme(alldata.idx);




base_hashes = hashes.basedata;
is_base = ismember(hashes.alldata,base_hashes);

figure('outerposition',[300 300 1800 901],'PaperUnits','points','PaperSize',[1800 901]); hold on
clear ax

% show baseline occupancy
ax(1) = subplot(1,2,1); hold on
display.plotBackgroundLabels(ax(1),alldata, R)

for i = 1:length(cats)
	plot(R(alldata.idx == cats(i) & is_base,1),R(alldata.idx == cats(i) & is_base,2),'.','Color',colors(cats{i}),'MarkerSize',5)
end

axis(ax(1),'off')
ax(1).XLim = [-31 31];
ax(1).YLim = [-31 31];
axis square
axlib.label(gca,'a','FontSize',28,'XOffset',-.01)

% show state distribution
ax = subplot(2,4,3); hold on
display.mondrian(basedata.idx,cats)
ax.Position = [.54 .58 .11 .34];
view([90 -90])
axlib.label(gca,'b','FontSize',28,'XOffset',-.01)


% show state distribution by prep
subplot(2,2,4); hold on
[h, P] = display.plotStateDistributionByPrep(basedata.idx, basedata.experiment_idx);
[~,idx]=sort(P(:,find(strcmp(cats,'regular'))),'descend');
P = P(idx,:);
delete(h)
h = bar(P,'stacked','LineStyle','none','BarWidth',1);
set(gca,'YLim',[0 1])

for i = 1:length(h)
	h(i).FaceColor = colors(cats{i});
end
xlabel('Crab #')
ylabel('Probability')
axlib.label(gca,'c','FontSize',28,'XOffset',-.01)

ax = subplot(2,4,4); hold on
ax.Position = [.7 .58 .25 .34];
display.stateLegend(gca,cats,2);


figlib.pretty()


figlib.saveall('Location',display.saveHere)

display.trimImage([mfilename '_1.png']);

% clean up workspace
init()