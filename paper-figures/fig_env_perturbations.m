% 
% in this figure we look at the effect of different environmental
% perturbations (pH, temperature & high K)

close all
init()


cats = categories(alldata.idx);
colors = display.colorscheme(alldata.idx);


C = struct;
C.high_temp = alldata.temperature > 19 & alldata.decentralized == 0 & alldata.Potassium == 1;

C.high_pH = alldata.pH > 9;
C.low_pH = alldata.pH < 7;
C.high_K = alldata.Potassium > 1;
fn = fieldnames(C);


figure('outerposition',[300 300 1444 1111],'PaperUnits','points','PaperSize',[1444 1111]); hold on


% pH
subplot(3,3,1); hold on
display.plotBackgroundLabels(gca,alldata,R)
this = alldata.pH ~=7 ;
C = alldata.pH(this);
sh = scatter(R(this,1),R(this,2),10,C,'filled');

colormap(colormaps.redblue);
ch = colorbar;
ch.Position = [.33 .7 .01 .1];
title(ch,'pH')




subplot(3,3,2); hold on

pH = alldata.pH;
pH(pH == 7) = NaN;
pH_space = 5.5:.1:10.5;
pH = discretize(pH,pH_space,pH_space(1:end-1)+diff(pH_space));
pH_space = unique(pH(~isnan(pH)));
display.plotStateProbabilitesVsSomething(alldata,pH,pH_space)
xlabel('pH')
ylabel('p(state)')


subplot(3,3,3); hold on
phdata = alldata.slice(alldata.pH~=7);
display.plotTransitionTriggeredDistributions(phdata,'silent')




% temperature
subplot(3,3,4); hold on
display.plotBackgroundLabels(gca,alldata,R)
this = alldata.temperature > 15 & alldata.decentralized == false & alldata.Potassium == 1;
C = alldata.temperature(this);
sh = scatter(R(this,1),R(this,2),10,C,'filled');

colormap(gca,flipud(colormaps.inferno));
ch = colorbar;
ch.Position = [.33 .4 .01 .1];
title(ch,['T (' char(176) 'C)'])


subplot(3,3,5); hold on

temp_space = 7:1:35;
temperature = alldata.temperature;
temperature(temperature < 7) = NaN;
temperature(alldata.decentralized) = NaN;
% % temperature(alldata.LP_channel == 'LP') = NaN;
% temperature(alldata.PD_channel == 'PD') = NaN;
temperature = discretize(temperature,temp_space,temp_space(1:end-1)+diff(temp_space));
temp_space = unique(temperature(~isnan(temperature)));
display.plotStateProbabilitesVsSomething(alldata,temperature,temp_space)
xlabel(['Temperature (' char(176) 'C)'])
ylabel('p(state)')


subplot(3,3,6); hold on
tempdata = alldata.slice(alldata.temperature > 20 & alldata.decentralized == false & alldata.Potassium == 1);
display.plotTransitionTriggeredDistributions(tempdata,'silent')







% high K
subplot(3,3,7); hold on
display.plotBackgroundLabels(gca,alldata,R)
this = alldata.Potassium > 1;

ph = plot(R(this,1),R(this,2),'k.');
lh = legend(ph,'2.5x [K^+]');
lh.Position = [.27 .11 .07 .03];



time_in_high_k = analysis.timeInHighK(alldata);

ax = subplot(3,3,8); hold on

display.mondrian(alldata.idx(alldata.Potassium>1));


subplot(3,3,9); hold on
highkdata = alldata.slice(alldata.Potassium > 1);
display.plotTransitionTriggeredDistributions(highkdata,'silent')


figlib.pretty()


figlib.label('XOffset',-.01,'FontSize',24,'YOffset',-.00)


figlib.saveall('Location',display.saveHere)
init()