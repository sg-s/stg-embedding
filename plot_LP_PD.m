function plotLP_PD(ax, data)

data = data';
data = reshape(data,length(data)/2,2);


cla(ax)
hold(ax,'on')

a = min(data(:));
data = data - a;

for i = 1:2
	neurolib.raster(ax,data(:,i),'yoffset',i+1,'deltat',1,'center',false)
end
set(ax,'YLim',[2 4],'XLim',[0 20])