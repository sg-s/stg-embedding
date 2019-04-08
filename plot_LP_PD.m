function plotLP_PD(ax, data)

data = reshape(data,length(data)/2,2);


cla(ax)
for i = 1:2
	neurolib.ISIraster(ax,data(:,i),'yoffset',i+1)
end