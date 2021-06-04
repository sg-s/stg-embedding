%%
% In this figure we plot prep states vs. perturbation 
% intensity 


%%
% First, pH preps. 

only_when = alldata.pH < 6.5;

figure('outerposition',[300 300 999 1111],'PaperUnits','points','PaperSize',[999 1111]); hold on
subplot(3,1,1); hold on
display.plotStatesVsPerturbationIntensity(alldata,only_when,'pH');

set(gca,'XDir','reverse','XLim',[0 1])


% now we do the same for temperature perturbations
subplot(3,1,2:3); hold on
only_when = alldata.temperature > 20 & alldata.decentralized == false;
display.plotStatesVsPerturbationIntensity(alldata,only_when,'temperature');
set(gca,'XLim',[-5 0])