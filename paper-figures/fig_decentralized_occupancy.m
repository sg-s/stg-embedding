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
figlib.tight
drawnow
% ax(2).Position = [.6 .62 .33 .35];


h = axlib.label(ax(1),'a','FontSize',28,'XOffset',0.01,'YOffset',-.03);
h = axlib.label(ax(2),'b','FontSize',28,'XOffset',-.04,'YOffset',-.04);
h = axlib.label(ax(4),'c','FontSize',28,'XOffset',-.08,'YOffset',-.02);
h = axlib.label(ax_mon(3),'d','FontSize',28,'XOffset',-.02,'YOffset',-.02);











% show pairwise changes in probabilities for each prep
P.D = decdata.slice(decdata.decentralized).probState;
P.C = decdata.slice(~decdata.decentralized).probState;

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
for i = 1:12
	subplot(3,4,i); hold on
	plot(P.C(:,i),P.D(:,i),'o','MarkerFaceColor',colors(cats{i}),'MarkerEdgeColor',colors(cats{i}))
	set(gca,'XLim',[0 1],'YLim',[0 1])
	plotlib.drawDiag(gca,'k--');
	title(cats{i},'Color',colors(cats{i}))

	if i == 9
		xlabel('p(control)')
		ylabel('p(decentralized)')
	end
end

figlib.pretty()



% measure variation in normal state before and after decentralization

Rd = NaN(length(unique_preps),2);
Rc = Rd;

before = struct;
after = struct;

for i = 1:length(unique_preps)
	Rc(i,:) = mean(R(alldata.decentralized == false & alldata.idx == 'normal' & alldata.experiment_idx == unique_preps(i),:));

	Rd(i,:) = mean(R(alldata.decentralized == true & alldata.idx == 'normal' & alldata.experiment_idx == unique_preps(i),:));


end

rm_this = isnan(sum(Rd,2));
Rd(rm_this,:) = [];
Rc(rm_this,:) = [];

DD = pdist2(nanmean(Rd),Rd);
DC = pdist2(nanmean(Rc),Rc);

figure('outerposition',[300 300 1200 1000],'PaperUnits','points','PaperSize',[1200 1000]); hold on
subplot(2,2,1); hold on
plot(Rc(:,1),Rc(:,2),'ko')
plot(Rd(:,1),Rd(:,2),'r+')
xlabel('tSNE-1 (a.u.)')
ylabel('tSNE-2 (a.u.)')
legend({'Before dec.','After'})
set(gca,'XLim',[-30 30],'YLim',[-30 30])

subplot(2,2,2); hold on
plot(DC,DD,'ks')
plotlib.drawDiag(gca,'k--')
xlabel('D_{before} (a.u.)')
ylabel('D_{after} (a.u.)')

subplot(2,2,3); hold on
[y,x] = histcounts(DD-DC,'Normalization','cdf','NumBins',100);
plot(x(1:end-1),y,'k')
plotlib.vertline(0,'k--')
display.plotCDFWithError(DD-DC);

[~,p] = adtest(DD-DC);
disp('AD test p = ')
disp(p)
set(gca,'XLim',[-15 15])
xlabel('D_{after} - D_{before}')

figlib.pretty()
figlib.label('FontSize',28,'XOffset',-.01)



figlib.saveall('Location',display.saveHere,'Format','png')
init()