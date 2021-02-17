% plots a shaded histogram

function h = shadedHistogram(X, BinEdges, options)

arguments
	X (:,1)
	BinEdges (:,1)
	options.Color = [0 0 0]
	options.FaceAlpha = .5;
end



hy = histcounts(X,'BinEdges',BinEdges,'Normalization','pdf');

BinCenters = BinEdges(1:end-1) + diff(BinEdges);

h = area(BinCenters,hy);
h.FaceAlpha = options.FaceAlpha;
h.FaceColor = options.Color;