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
	times_bw_transitions{i} = display.plotDwellTimes(idx,time);
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



% now make a histogram showing cdfs of times between transitions
figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
all_x  = [];
all_y = [] ;
for i = 1:length(condition)
	all_x = [all_x; repmat(categorical(condition(i)),length(times_bw_transitions{i}),1)];
	all_y = [all_y; log10(times_bw_transitions{i})];
end

vs = violinplot(all_y,all_x);
ylabel('Time between transitions (s)')

figlib.pretty
set(gca,'XLim',[0 7],'YTick',[1:3],'YTickLabel',{'10','100','1000'})
set(gca,'YLim',[1 3])