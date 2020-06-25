% this figure shows dwell times of each state, in each condition

if ~exist('alldata','var')
    init()
end


idx = alldata.idx;
time = alldata.time_since_mod_on;
cats = categories(idx);
colors = display.colorscheme(cats);

close all



figure('outerposition',[300 300 1333 901],'PaperUnits','points','PaperSize',[1333 901]); hold on

condition = {'baseline','decentralized','RPCH','proctolin','oxotremorine','serotonin','CCAP','CabTrp1a'};

for i = 1:length(condition)
	subplot(2,4,i); hold on
	this = filterData(alldata,condition{i});
	n_transitions = display.plotTransitionGraph(idx(this),time(this));
	title({condition{i} , [' n=' mat2str(n_transitions) ', ' mat2str((sum(this)*20)/3600,2) ,'h']},'FontWeight','normal')
end

figlib.pretty


clearvars -except p alldata data
