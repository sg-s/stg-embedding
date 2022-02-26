% 
% in this figure we look at the effect of different environmental
% perturbations (pH, temperature & high K)

close all
init()


cats = categories(alldata.idx);
colors = display.colorscheme(alldata.idx);

silent_idx = find(strcmp(cats,'silent'));

figure('outerposition',[300 300 1200 1300],'PaperUnits','points','PaperSize',[1200 1300]); hold on


% make axes
ax.map = subplot(2,2,1); hold on
% ax.ph_dist = subplot(4,2,2); hold on
% ax.temp_dist = subplot(4,2,4); hold on
% ax.ph_dist.XLim = [5.5 11];

ax.treemaps.control = subplot(4,5,11); hold on
ax.treemaps.high_temp = subplot(4,5,14); hold on
ax.treemaps.low_ph = subplot(4,5,13); hold on
ax.treemaps.high_ph = subplot(4,5,12); hold on
ax.treemaps.high_k = subplot(4,5,15); hold on

ax.silentmaps.high_k = subplot(4,5,20); hold on
ax.silentmaps.high_temp = subplot(4,5,19); hold on
ax.silentmaps.low_ph = subplot(4,5,18); hold on


ax.legend = subplot(4,5,16:17);

conditions = [alldata.pH>9.5 ...
	alldata.temperature > 25 & alldata.decentralized == 0 & alldata.Potassium == 1 ...
	alldata.Potassium > 1];


% this takes a while, so let's memoize it
P = cacheFcn(@analysis.findRelativeAbundanceInMap, R, conditions);
P = normalize(P);


display.plotBackgroundLabels(ax.map,alldata, R);

% show where the different perturbations are likely to be
Markers = {'o','d','^'};
Colors = [0 0 0; .7 .7 .7; 1 1 1];
MarkerEdgeColor = [0 0 0; .7 .7 .7; 1 0 0 ];

for i = size(conditions,2):-1:1
	this = P(:,i) > 1; % 3 sigma
	plot(ax.map,R(this,1),R(this,2),Markers{i},'MarkerFaceColor',Colors(i,:),'MarkerEdgeColor',MarkerEdgeColor(i,:),'MarkerSize',5);
	lh(i) = plot(ax.map,NaN,NaN,Markers{i},'MarkerFaceColor',Colors(i,:),'MarkerSize',15,'MarkerEdgeColor',MarkerEdgeColor(i,:));
end
legend(lh,{'pH > 9.5','T > 25C','2.5\times[K^+]'},'Location','eastoutside')




% compute mean distance traveled as pH is varied

% pH = alldata.pH;

% pH_preps = unique(alldata.experiment_idx(alldata.pH ~=7 ));

% Distance = @(RR) (sqrt(sum((RR(2:end,:) - RR(1:end-1,:)).^2,2)));

% BinStarts = 5.5:.01:10.5;
% X = repmat(BinStarts,length(pH_preps),1);

% for i = 1:length(pH_preps)
% 	this = alldata.experiment_idx == pH_preps(i);
% 	this_pH = alldata.pH(this);
% 	d = [Distance(R(this,:)); NaN];
% 	BinSize = 1;
% 	X(i,:)=binapply(this_pH,d,@nanmean,'BinSize',BinSize,'BinStarts',BinStarts);
% end

% M = nanmean(X);
% S = nanstd(X);

% [lh,sh] = plotlib.errorShade(ax.ph_dist,BinStarts,M,S,'Color',[.5 .5 .5]);
% sh.LineWidth = 2;
% lh.Color = 'k';

% ax.ph_dist.XLim = [5.5 10.2];



% G = discretize(pH,pH_space);
% mean_dist = splitapply(@(x) mean(Distance(x)),R,G);
% std_dist = splitapply(@(x) std(Distance(x))/sqrt(length(x)),R,G);
% errorbar(ax.ph_dist,pH_space(2:end),mean_dist,std_dist,'k','LineWidth',1.5)

% xlabel(ax.ph_dist,'pH')
% yh = ylabel(ax.ph_dist,'Mean distance travelled in map (a.u.)');
% yh.Position = [5 -1 -1];
% plotlib.vertline(ax.ph_dist,7.8,'k--')

% temperature = alldata.temperature;
% temperature(temperature < 3) = NaN;
% temperature(alldata.Potassium ~= 1) = NaN;
% temperature(alldata.decentralized) = NaN;



% temp_preps = unique(alldata.experiment_idx(alldata.pH == 7 & alldata.Potassium == 1));


% BinStarts = 5:.2:35;
% X = repmat(BinStarts,length(temp_preps),1);

% for i = 1:length(temp_preps)
% 	this = alldata.experiment_idx == temp_preps(i);
% 	this_pH = temperature(this);
% 	d = [Distance(R(this,:)); NaN];
% 	BinSize = 1;
% 	X(i,:)=binapply(this_pH,d,@nanmean,'BinSize',BinSize,'BinStarts',BinStarts);
% end

% M = nanmean(X);
% S = nanstd(X);

% [lh,sh] = plotlib.errorShade(ax.temp_dist,BinStarts,M,S,'Color',[.5 .5 .5]);
% sh.LineWidth = 4;
% lh.Color = 'k';
% ax.temp_dist.XLim = [5 32];
% plotlib.vertline(ax.temp_dist,11,'k--')

% G = discretize(temperature,temp_space);
% mean_dist = splitapply(@(x) mean(Distance(x)),R,G);
% std_dist = splitapply(@(x) std(Distance(x))/sqrt(length(x)),R,G);




% % errorbar(ax.temp_dist,temp_space(2:end),mean_dist,std_dist,'k','LineWidth',1.5)
% xlabel(ax.temp_dist,display.tempLabel)
% ax.temp_dist.YLim(1) = 0;
% ax.ph_dist.YLim(1) = 0;

axes(ax.treemaps.control)
this = decdata.slice(~decdata.decentralized);
this = alldata.slice(alldata.decentralized == false & alldata.Potassium == 1 & alldata.pH == 7 & alldata.temperature < 15 & alldata.temperature > 10 & alldata.baseline == 1);


P = this.probState;
display.mondrian(mean(P),cats);
view([90 -90])
title('Baseline','FontWeight','normal','FontSize',20)

axes(ax.treemaps.high_temp)
this = alldata.slice(alldata.temperature > 25 & ~alldata.decentralized & alldata.pH ==7 & alldata.Potassium == 1);
P = this.probState;
ph = display.mondrian(mean(P),cats);
view([90 -90])

display.boxPatch(ph(silent_idx));
title(['T > 25' char(176)  'C'],'FontWeight','normal','FontSize',20)




axes(ax.silentmaps.high_temp)

[~, J] = analysis.computeTransitionMatrix(this.idx,this.time_offset);
allJ = J;
P = J(:,silent_idx);
P(silent_idx) = 0;
display.mondrian(P,cats)
view([90 -90])

th = title(['(' mat2str(sum(P)) ' transitions)']);
th.Position = [-.15 .5];
th.FontWeight = 'normal';


axes(ax.treemaps.low_ph)
this = alldata.slice(alldata.pH < 6.5);
P = this.probState;
ph = display.mondrian(mean(P),cats);
view([90 -90])
title('pH < 6.5','FontWeight','normal','FontSize',20)
display.boxPatch(ph(silent_idx));

axes(ax.silentmaps.low_ph)
[~, J] = analysis.computeTransitionMatrix(this.idx,this.time_offset);
allJ = allJ  + J;
P = J(:,silent_idx);
P(silent_idx) = 0;
display.mondrian(P,cats);
view([90 -90])

th = title(['(' mat2str(sum(P)) ' transitions)']);
th.Position = [-.15 .5];
th.FontWeight = 'normal';

axes(ax.treemaps.high_ph)
this = alldata.slice(alldata.pH > 9.5);
P = this.probState;
display.mondrian(mean(P),cats);
view([90 -90])
title('pH > 9.5','FontWeight','normal','FontSize',20)


axes(ax.treemaps.high_k)
this = alldata.slice(alldata.Potassium > 1);
P = this.probState;
ph = display.mondrian(mean(P),cats);
view([90 -90])
title('2.5x [K^+]_o','FontWeight','normal','FontSize',20)
display.boxPatch(ph(silent_idx))

axes(ax.silentmaps.high_k)
[~, J] = analysis.computeTransitionMatrix(this.idx,this.time_offset);
allJ = allJ  + J;
P = J(:,silent_idx);
P(silent_idx) = 0;
display.mondrian((P),cats);
view([90 -90])
th = title(['(' mat2str(sum(P)) ' transitions)']);
th.Position = [-.15 .5];
th.FontWeight = 'normal';

display.stateLegend(ax.legend,cats,'NumColumns',2)


% ax.temp_dist.Position = [.57 .6 .334 .14];
% ax.ph_dist.Position = [.57 .79 .334 .14];
ax.map.Position = [.3 .55 .4 .4];


figlib.pretty()

axlib.label(ax.map,'a','FontSize',24,'XOffset',.01,'YOffset',-.02)
% axlib.label(ax.ph_dist,'b','FontSize',24,'XOffset',-.04,'YOffset',.00)
axlib.label(ax.treemaps.control,'b','FontSize',24,'XOffset',-.02,'YOffset',.00)
axlib.label(ax.silentmaps.low_ph,'c','FontSize',24,'XOffset',-.0,'YOffset',.00)

a = annotation('arrow',[.5175 .2566],[.04 .07]);
a.Position = [0.5175 0.2566 0.0400 0.0700];
a.LineWidth = 2;

a = annotation('arrow',[.5175 .2566],[.04 .07]);
a.Position = [.6803 .256 .04 .2];
a.LineWidth = 2;

a = annotation('arrow',[.5175 .2566],[.04 .07]);
a.Position = [0.8431 0.2560 0.0250 0.1450];
a.LineWidth = 2;

figlib.saveall('Location',display.saveHere)

display.trimImage([mfilename '_1.png']);


% clean up workspace
init()