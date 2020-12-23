% in this figure we make a triangulation of the embedded data to compare
% differences in metrics along the edges to show that the embedding 
% is doing something useful, and is preserving some useful information
% in a smooth manner

close all
init()

% this convoluted syntax is to ensure that 
% the size of the points in the triangulation is the same
% as the points we have
DT = triangulation(delaunay(R),R(:,1),R(:,2));
assert(all(R(:,1) == DT.Points(:,1)),'triangulation is flawed!')
incenters = incenter(DT);


metrics = {'PD_burst_period','PD_duty_cycle'};
Labels = {'Triadic difference in T_{PD} (s)','Triadic difference in DC_{PD}'};
MetricsDiff = struct;

for i = 1:length(metrics)
	MetricsDiff.(metrics{i}) = nanmax(allmetrics.(metrics{i})(DT.ConnectivityList),[],2) - nanmin(allmetrics.(metrics{i})(DT.ConnectivityList),[],2);
end


figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

clear ax
ax(1).map = subplot(3,4,[1 2 5 6]); hold on
axis off
axis square
ax(2).map = subplot(3,4,[3 4 7 8]); hold on
axis off
axis square

ax(1).dist = subplot(3,4,[9 10]); hold on
ylabel('p.d.f')
xlabel(Labels{1})
ax(2).dist = subplot(3,4,[11 12]); hold on
xlabel(Labels{2})


% PCA the data and triangulate it
P = pca(VectorizedData');
P = P(:,1:2);
DTP = triangulation(delaunay(P),P(:,1),P(:,2));
assert(all(P(:,1) == DTP.Points(:,1)),'triangulation is flawed!')
incentersP = incenter(DTP);

MetricsDiffP = struct;

for i = 1:length(metrics)
	MetricsDiffP.(metrics{i}) = nanmax(allmetrics.(metrics{i})(DTP.ConnectivityList),[],2) - nanmin(allmetrics.(metrics{i})(DTP.ConnectivityList),[],2);
end


for i = 1:2
	

	axes(ax(i).map)
	plot(R(:,1),R(:,2),'.','Color',[1 .9 .9],'MarkerSize',40)
	scatter(ax(i).map,incenters(:,1),incenters(:,2),5,MetricsDiff.(metrics{i}),'filled')

	Limits = [min(MetricsDiff.(metrics{i})) max(MetricsDiff.(metrics{i}))];
	caxis(Limits)
	ch = colorbar;
	ch.Location = 'southoutside';
	title(ch,Labels{i})

	if i == 2
		ch.Position = [.7 .33 .2 .02];
	else
		ch.Position = [.3 .33 .2 .02];
	end

	if Limits(2) > 3
		Limits(2) = 3;
	end



	% also show distribution and compare with null distribution and distribution for PCA

	axes(ax(i).dist)

	display.plotCDFWithError(MetricsDiff.(metrics{i}),[1 0 0],1e3)

	display.plotCDFWithError(MetricsDiffP.(metrics{i}),[0 0 1],1e3)

	clear V
	V(:,1) = veclib.shuffle(DT.ConnectivityList(:,1));
	V(:,2) = veclib.shuffle(DT.ConnectivityList(:,2));
	V(:,3) = veclib.shuffle(DT.ConnectivityList(:,3));

	ShuffledDiff = nanmax(allmetrics.(metrics{i})(V),[],2) - nanmin(allmetrics.(metrics{i})(V),[],2);


	
	display.plotCDFWithError(ShuffledDiff,[0 0 0],1e3)
	
end

colormap(flipud(gray))


set(ax(1).dist,'XScale','log')
set(ax(2).dist,'XScale','log')

return


figlib.pretty()

axlib.move(ax(2).dist,'right',.05)
axlib.move(ax(2).map,'right',.05)



figlib.saveall('Location',display.saveHere)
init()