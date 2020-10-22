% this figure shows dwell times of each state, in each condition

close all
init()


cats = categories(moddata.idx);
colors = display.colorscheme(cats);


figure('outerposition',[300 300 1600 901],'PaperUnits','points','PaperSize',[1400 901]); hold on

% first show the decentralized case
ax(1) = subplot(2,3,1); hold on
preps = moddata.slice(moddata.decentralized & moddata.modulator == 0);
n_transitions = display.plotTransitionGraph(preps.idx,preps.time_offset);

h = length(preps.idx)*20/60/60;
title({'decentralized' , [' n=' mat2str(n_transitions) ', ' mat2str(h,2)  'h']},'FontWeight','normal')

modnames = {'RPCH','proctolin','oxotremorine','serotonin','CabTrp1a'};





for i = 1:length(modnames)
	ax(i+1) = subplot(2,3,i+1); hold on


	% find all preps where this mod is used
	preps = unique(moddata.experiment_idx(moddata.(modnames{i}) > 0));
	preps = moddata.slice(ismember(moddata.experiment_idx,preps) & moddata.decentralized);


	n_transitions = display.plotTransitionGraph(preps.idx,preps.time_offset);
	

	h = length(preps.idx)*20/60/60;
	title({modnames{i} , [' n=' mat2str(n_transitions) ', ' mat2str(h,2)  'h']},'FontWeight','normal')
end


% make fake plots for a legend
clear lh
for i = 1:length(cats)
    lh(i) = plot(ax(3),NaN,NaN,'.','MarkerSize',50,'DisplayName',cats{i},'Color',colors(cats{i}));
end


L = legend(lh);
L.NumColumns = 1;

figlib.pretty

axlib.move(ax,'left',.1);

L.Position = [.85 .07 .1 .9];


figlib.saveall('Location',display.saveHere)
init()