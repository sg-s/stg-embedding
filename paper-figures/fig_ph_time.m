%%
% In this figure I look at how behaviour changes with perturbation intensity on a prep-by-prep basis

init()
close all

pH_preps = unique(alldata.experiment_idx(alldata.pH ~= 7));



C = display.colorscheme(alldata.idx);
cats = categories(alldata.idx);
CC = zeros(length(cats),3);

for i = 1:length(cats)
	CC(i,:) = C.(cats{i});
end



figure('outerposition',[300 300 1100 1901],'PaperUnits','points','PaperSize',[1100 1901]); hold on

ax = subplot(4,1,1); 
ax.Position = [.5 .8 .4 .15];
display.stateLegend(ax,cats, 2);

for i = 1:length(pH_preps)
	subplot(4,2,i+2); hold on
	idx = alldata.idx(alldata.experiment_idx == pH_preps(i));
	pH = alldata.pH(alldata.experiment_idx == pH_preps(i));
	time = (1:length(pH))*20;
	pH(end) = NaN;
	ph = patch(time,pH,double(idx),'EdgeColor','flat','Marker','o','MarkerFaceColor','flat');
	ph.MarkerSize = 7;
	ylabel('pH')
	set(gca,'XLim',[0 15e3],'YLim',[5.5 10.5])
	xlabel('Time (s)')
end
colormap(CC)


figlib.pretty


figlib.saveall('Location',display.saveHere)


% clean up workspace
init()