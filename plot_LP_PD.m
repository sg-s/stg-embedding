function plotLP_PD(ax, data)

data = reshape(data,length(data)/2,2);


cla(ax)
hold(ax,'on')

a = data(1,1);

for i = 1:2
	neurolib.raster(ax,data(:,i)-a,'yoffset',i+1,'deltat',1)
end
set(ax,'YLim',[2 4],'XLim',[0 10])