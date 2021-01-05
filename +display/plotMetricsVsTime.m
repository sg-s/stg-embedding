% plots a time series of some metric
% if a vector is provided, it is simply plotted
% if a matrix is provided, the error is computed
% across preps, and the error is indicated using shading

function plotMetricsVsTime(time, X, Color)

% plot a line at time = 0
plot([0 0],[-1e3 1e3],':','Color',[.5 .5 .5])

if isvector(X)
	plot(time,X,'Color',Color,'LineWidth',3);
	return
end



% plot variability of firing rates
E = nanstd(X)./sqrt(sum(~isnan(X)));
h = plotlib.errorShade(gca,time,nanmean(X),E,'Color',Color,'LineWidth',3);

delete(h(2:3));

