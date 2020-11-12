% the point of this figure is to show ISIs
% from each cluster to show that the clustering is more or less
% reasonable 

close all
init()


show_these_states = categorical({'normal','irregular-bursting','LP-weak-skipped','irregular','PD-silent','aberrant-spikes','LP-silent-PD-bursting','LP-silent','silent'});




figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on


for i = 1:length(show_these_states)
	ax(i) = subplot(3,3,i); hold on
end



figlib.pretty()

for i = 1:length(show_these_states)
	display.plotNISIs(ax(i),alldata,500,show_these_states(i));
end



% cleanup
figlib.saveall('Location',display.saveHere)

init()