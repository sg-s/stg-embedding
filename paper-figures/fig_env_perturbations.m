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
ax.ph_dist = subplot(4,2,2); hold on
ax.temp_dist = subplot(4,2,4); hold on
ax.ph_dist.XLim = [5.5 11];

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
f = memoize(@analysis.findRelativeAbundanceInMap);
P = normalize(f(R,conditions));


display.plotBackgroundLabels(ax.map,alldata, R);

% show where the different perturbations are likely to be
Colors = [1 0 0; 0 0 0; .1 .9 .1];
for i = 1:size(conditions,2)
	this = P(:,i) > 1; % 3 sigma
	plot(ax.map,R(this,1),R(this,2),'.','Color',Colors(i,:));
	lh(i) = plot(ax.map,NaN,NaN,'.','Color',Colors(i,:),'MarkerSize',24);
end
legend(lh,{'pH > 9.5','T > 25C','2.5x[K^+]'})

% compute mean distance traveled as pH is varied

pH = alldata.pH;
pH(pH == 7) = NaN;
pH_space = 5.5:.5:10.5;
G = discretize(pH,pH_space);

Distance = @(RR) (sqrt(sum((RR(2:end,:) - RR(1:end-1,:)).^2,2)));

mean_dist = splitapply(@(x) mean(Distance(x)),R,G);
std_dist = splitapply(@(x) std(Distance(x))/sqrt(length(x)),R,G);
errorbar(ax.ph_dist,pH_space(2:end),mean_dist,std_dist,'k','LineWidth',1.5)
xlabel(ax.ph_dist,'pH')
yh = ylabel(ax.ph_dist,'Mean distance travelled in map (a.u.)');
yh.Position = [5 -1 -1];

temp_space = 7:2:35;
temperature = alldata.temperature;
temperature(temperature < 7) = NaN;
temperature(alldata.Potassium ~= 1) = NaN;
temperature(alldata.decentralized) = NaN;

G = discretize(temperature,temp_space);
mean_dist = splitapply(@(x) mean(Distance(x)),R,G);
std_dist = splitapply(@(x) std(Distance(x))/sqrt(length(x)),R,G);
errorbar(ax.temp_dist,temp_space(2:end),mean_dist,std_dist,'k','LineWidth',1.5)
xlabel(ax.temp_dist,display.tempLabel)
ax.temp_dist.YLim(1) = 0;
ax.ph_dist.YLim(1) = 0;

axes(ax.treemaps.control)
this = decdata.slice(~decdata.decentralized);
P = this.probState;
display.mondrian(mean(P),cats);
view([90 -90])
title('Baseline','FontWeight','normal','FontSize',20)

axes(ax.treemaps.high_temp)
this = alldata.slice(alldata.temperature > 25 & ~alldata.decentralized & alldata.pH ==7 & alldata.Potassium == 1);
P = this.probState;
ph = display.mondrian(mean(P),cats);
view([90 -90])
display.boxPatch(ph(11));
title(['T > 25' char(176)  'C'],'FontWeight','normal','FontSize',20)


axes(ax.silentmaps.high_temp)
J = analysis.computeTransitionMatrix(this.idx,this.time_offset);
P = J(:,silent_idx);
P(silent_idx) = 0;
display.mondrian((P),cats)
view([90 -90])

axes(ax.treemaps.low_ph)
this = alldata.slice(alldata.pH < 6.5);
P = this.probState;
ph = display.mondrian(mean(P),cats);
view([90 -90])
title('pH < 6.5','FontWeight','normal','FontSize',20)
display.boxPatch(ph(11));

axes(ax.silentmaps.low_ph)
J = analysis.computeTransitionMatrix(this.idx,this.time_offset);
P = J(:,silent_idx);
P(silent_idx) = 0;
display.mondrian(P,cats);
view([90 -90])



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
display.boxPatch(ph(11))

axes(ax.silentmaps.high_k)
J = analysis.computeTransitionMatrix(this.idx,this.time_offset);
P = J(:,silent_idx);
P(silent_idx) = 0;
display.mondrian((P),cats);
view([90 -90])

display.stateLegend(ax.legend,cats,2)


ax.temp_dist.Position = [.57 .6 .334 .14];
ax.ph_dist.Position = [.57 .79 .334 .14];
ax.map.Position = [.1 .55 .4 .4];


figlib.pretty()

axlib.label(ax.map,'a','FontSize',24,'XOffset',.01,'YOffset',-.02)
axlib.label(ax.ph_dist,'b','FontSize',24,'XOffset',-.04,'YOffset',.00)
axlib.label(ax.treemaps.control,'c','FontSize',24,'XOffset',-.02,'YOffset',.00)
axlib.label(ax.silentmaps.low_ph,'d','FontSize',24,'XOffset',-.0,'YOffset',.00)

a = annotation('arrow',[.5175 .2566],[.04 .07]);
a.Position = [0.5175 0.2566 0.0400 0.0700];

a = annotation('arrow',[.5175 .2566],[.04 .07]);
a.Position = [.6803 .256 .04 .2];

a = annotation('arrow',[.5175 .2566],[.04 .07]);
a.Position = [0.8431 0.2560 0.0250 0.1450];


figlib.saveall('Location',display.saveHere)

% clean up workspace
init()