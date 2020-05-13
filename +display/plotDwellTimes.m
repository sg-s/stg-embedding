function plotDwellTimes(idx, time)



cats = categories(idx);
colors = display.colorscheme(cats);


% compute dwell times 
dwell_times = 20*analysis.dwellTimes(idx,time);


m = nanmean(dwell_times');
e = nanstd(dwell_times')/sqrt(size(dwell_times,2));




total_time = 20*histcounts(idx);
for i = 1:length(cats)
	h = errorbar(total_time(i),m(i),e(i),e(i),0,0,'LineStyle','none','Color',colors(cats{i}),'Marker','.','MarkerFaceColor',colors(cats{i}),'MarkerSize',20);
end
rm_this = isnan(total_time) | isnan(m);
ff = fit(total_time(~rm_this)',m(~rm_this)','poly1','Lower',[-Inf 0],'Upper',[Inf 0]);
xx = logspace(2,6,100);
plot(xx,ff(xx),'k:')

set(gca,'XScale','log','YScale','log','YLim',[10 1e3])

