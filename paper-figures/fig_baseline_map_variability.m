% we look at the map and see what it tells us about baseline variability 

close all
init()


% find basedata in alldata
[~,base]=ismember(hashes.basedata,hashes.alldata);


in_base = false(length(R),1);
in_base(base) = true;

[clustering_prob, rand_prob,N, unique_preps]=analysis.clustering(alldata, R, 'experiment_idx', in_base & alldata.idx == 'normal');


figure('outerposition',[300 300 1300 801],'PaperUnits','points','PaperSize',[1300 801]); hold on
clear ax
ax.map = subplot(1,2,1); hold on
display.plotBackgroundLabels(gca,alldata, R)
axis off
axis square
ax.map.XLim = [-35 35];
ax.map.YLim = [-35 35];




ax.cdf = subplot(2,2,4); hold on

colors = display.colorscheme(alldata.idx);

display.plotSortedCDF(clustering_prob,'Color',colors.normal,'LineWidth',3)
display.plotSortedCDF(rand_prob,'k','LineWidth',3)


xlabel('Probability of N closest points belonging to same prep.')
ylabel('CDF')


temp = clustering_prob;
temp(N<100) = NaN;

C = lines;


ax.varied = subplot(2,4,3); hold on
ax.nice = subplot(2,4,4); hold on
figlib.pretty()

% show widely scatter prep
[~,idx]=min(temp);
this = alldata.experiment_idx == unique_preps(idx) & alldata.idx == 'normal';
plot(ax.map,R(this,1),R(this,2),'^','MarkerSize',8,'MarkerFaceColor',colors.normal,'MarkerEdgeColor','k')




prep = alldata.slice(alldata.experiment_idx == unique_preps(idx) & alldata.idx == 'normal');
prep.snakePlot(ax.varied);



% show clustered prep
[~,idx]=max(temp);
this = alldata.experiment_idx == unique_preps(idx) & alldata.idx == 'normal';
plot(ax.map,R(this,1),R(this,2),'o','MarkerSize',10,'MarkerFace',colors.normal,'MarkerEdgeColor','w')

prep = alldata.slice(alldata.experiment_idx == unique_preps(idx) & alldata.idx == 'normal');
prep.snakePlot(ax.nice);



ax.map.Position = [.05 .05 .5 .9];
ax.cdf.XLim = [0 1];


ax.varied.Position = [.56 .58 .11 .33];
ax.nice.Position = [.75 .58 .11 .33];

drawnow;

figlib.saveall('Location',display.saveHere)


% clean up workspace
init()