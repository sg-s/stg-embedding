function raster(data, X, YOffset)

arguments
	data (1,1) embedding.DataStore
	X (:,1) double 
	YOffset (:,1) = zeros(length(X),1)
end

colors = display.colorscheme(data.idx);


for i = 1:length(X)

	PD = data.PD(X(1),:);
	LP = data.LP(X(1),:);

	xoffset = min([PD(:); LP(:)]);
	PD = PD - xoffset;
	LP = LP - xoffset;

	neurolib.raster(PD,'Color',colors.PD,'deltat',1,'yoffset',YOffset(i),'center',false)
	neurolib.raster(LP,'Color',colors.LP,'deltat',1,'yoffset',YOffset(i)+1,'center',false)

	% plot a thick line on the left to indicate the label
	plot([0 0],[YOffset(i) YOffset(i)+2],'LineWidth',5,'Color',colors(data.idx(X(i))))
end