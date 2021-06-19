% makes a figure showing where the decentralized data is.
% the point is to show that baseline data is surprisingly variable


init()
close all

cats = categories(alldata.idx);
colors = display.colorscheme(alldata.idx);
Alpha = .05;

things_to_measure = {'PD_burst_period','LP_burst_period'};
t_before = 10;
T = (0:-1:-t_before+1)*20;

dec_hashes = hashes.decdata(decdata.decentralized);
is_decentralized = ismember(hashes.alldata,dec_hashes) & alldata.decentralized;

figure('outerposition',[300 300 1800 1300],'PaperUnits','points','PaperSize',[1800 1300]); hold on

clear ax
ax.map = subplot(2,2,1); hold on
ax.distances = subplot(4,4,3); hold on
ax.legend = subplot(4,4,4); hold on;
ax.mondrian = subplot(4,2,4); hold on;
ax.J = subplot(2,3,4); hold on
ax.PD_burst_period = subplot(2,3,5); hold on
ax.LP_burst_period = subplot(2,3,6); hold on


% show baseline occupancy

display.plotBackgroundLabels(ax.map,alldata, R)

for i = 1:length(cats)
	plot(ax.map,R(alldata.idx == cats(i) & is_decentralized,1),R(alldata.idx == cats(i) & is_decentralized,2),'.','Color',colors(cats{i}),'MarkerSize',5)
end

axis(ax.map,'off')
ax.map.XLim = [-31 31];
ax.map.YLim = [-31 31];
axis(ax.map,'square') 
axis(ax.distances,'square')

figlib.pretty('FontSize',15)



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






c = lines;

scatter(ax.distances,S_before,S_after,24,'MarkerFaceColor','k','MarkerEdgeColor','k','MarkerFaceAlpha',.5)
plotlib.drawDiag(ax.distances,'k--');
ax.distances.XLim = [0 12];
ax.distances.YLim = [0 12];
xlabel(ax.distances,{'Mean distance before',' decentralization (a.u.)'})
ylabel(ax.distances,{'Mean distance after','decentralization (a.u.)'})

axes(ax.distances)
[~,handles] = statlib.pairedPermutationTest(S_before,S_after,1e4,true);

handles.line.Color = 'k';


lh = display.stateLegend(ax.legend,cats);



ax_mon = display.pairedMondrian(ax.mondrian,decdata,~decdata.decentralized, decdata.decentralized,'baseline','decentralized');

only_when = decdata.decentralized;
[J, ~, marginal_counts, p_below, p_above]  = analysis.computeTransitionMatrix(decdata.idx(only_when),decdata.time_offset(only_when));

% % now bootstrap the J
% foo = @analysis.computeTransitionMatrix;
% JB = analysis.boostrapExperiments(foo,{decdata.idx(only_when),decdata.time_offset(only_when)},decdata.experiment_idx(only_when),1e3);

% frac_below = mean(JB >= J0,3) < Alpha;
% frac_above = mean(JB <= J0,3) < Alpha;


display.plotTransitionMatrix(J,cats,p_below, p_above,'ax',ax.J,'ShowScale',true);





[CV, CV0] = analysis.measureRegularCVBeforeOrAfterTransitions(decdata,decmetrics,decdata.decentralized,'things_to_measure',things_to_measure,'T',t_before);



th = display.plotVariabilityBeforeTransition(CV,CV0,ax,T);
th(1).Position(2) = .06;
th(2).Position(2) = .06;
ax.PD_burst_period.YLim = [0 .08];
ax.LP_burst_period.YLim = [0 .08];
ax.PD_burst_period.XLim = [-200 10];
ax.LP_burst_period.XLim = [-200 10];


ax_mon(1).Position = [0.45 0.37 0.1 0.2];
ax_mon(2).Position = [0.56 0.37 0.1 0.2];
ax_mon(3).Position = [0.72 0.37 0.2 0.2];


ax.map.Position = [.04 .51 .4 .45];
ax.distances.Position = [0.45 0.71 0.2 0.25];
ax.legend.Position = [0.75 0.77 0.16 0.16];
ax.mondrian.Position = [0.57 0.55 0.33 0.16];
ax.PD_burst_period.Position = [0.45 0.11 0.21 0.18];
ax.LP_burst_period.Position = [0.71 0.11 0.21 0.18];
ax.J.Position = [.1 .11 .27 .37];

ax_mon(1).FontSize = 15;
ax_mon(2).FontSize = 15;
ax_mon(3).FontSize = 15;

ax_mon(3).LineWidth = 1.5;

ylabel(ax.PD_burst_period,'CV(T)')
h = xlabel(ax.PD_burst_period,'Time before transition (s)');
h.Position = [40 -.01];
h.FontSize = 20;

ax_mon(3).Position(1) = ax.LP_burst_period.Position(1);


drawnow
% ax(2).Position = [.6 .62 .33 .35];


h1 = axlib.label(ax.map,'a','FontSize',28,'XOffset',0.04,'YOffset',-.03);
h2 = axlib.label(ax.J,'e','FontSize',28,'XOffset',-.02);
h2.Position(1) = h1.Position(1);

h1 = axlib.label(ax.distances,'b','FontSize',28,'XOffset',-.02,'YOffset',-.04);
h2 = axlib.label(ax_mon(1),'c','FontSize',28,'XOffset',-.08,'YOffset',-.02);
h2.Position(1) = h1.Position(1);

axlib.label(ax_mon(3),'d','FontSize',28,'XOffset',-.02,'YOffset',-.02);

h2 = axlib.label(ax.PD_burst_period,'f','FontSize',28);
h2.Position(1) = h1.Position(1);
ax.J.Position = [.1 .05 .3 .47];


lh.Position = [.71 .72 .2 .23];




figlib.saveall('Location',display.saveHere)

display.trimImage([mfilename '_1.png']);

init




return








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
	Rc(i,:) = mean(R(alldata.decentralized == false & alldata.idx == 'regular' & alldata.experiment_idx == unique_preps(i),:));

	Rd(i,:) = mean(R(alldata.decentralized == true & alldata.idx == 'regular' & alldata.experiment_idx == unique_preps(i),:));


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