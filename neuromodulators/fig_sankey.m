

if ~exist('alldata','var')
    init()
end


idx = alldata.idx;
time = alldata.time_since_mod_on;
cats = categories(idx);
colors = display.colorscheme(cats);

close all




% how do preps recover in different neuromodualtors? 

figure('outerposition',[300 300 1444 901],'PaperUnits','points','PaperSize',[1444 901]); hold on

condition = {'RPCH','proctolin','serotonin','CabTrp1a'};

for i = 1:length(condition)
	subplot(2,2,i); hold on
	this = filterData(alldata,condition{i});

	this_idx = idx(this);

	J = embedding.computeTransitionMatrix(this_idx, time(this));

	% ignore transitions that happen only once or twice
	J(J<3) = 0;

	n_transitions = sum(J(:));

	J = J/sum(J(:));


	display.plotSankey(J, find(strcmp(cats,'normal')), cats, colors);

	title([condition{i} ' (n=' mat2str(n_transitions) ')'],'FontWeight','normal')
end

figlib.pretty


clearvars -except p alldata data





% diversity in recovery in decentralized preps