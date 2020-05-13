close all

if ~exist('alldata','var')
    init()
end






figure('outerposition',[300 300 1301 901],'PaperUnits','points','PaperSize',[1301 901]); hold on


condition = {'baseline','decentralized','RPCH','proctolin','oxotremorine','serotonin'};

for i = 1:length(condition)
	subplot(2,3,i); hold on
	these = filterData(alldata,condition{i});
	idx = alldata.idx(these);
	time = alldata.time_since_mod_on(these);
	display.plotDwellTimes(idx,time)
	if i > 3
		xlabel('Total time in state (s)')
	end
	if i == 1 | i == 4
		ylabel('Dwell time (s)')
	end
	title(condition{i},'FontWeight','normal')
	set(gca,'XLim',[10 1e5])

end


figlib.pretty
