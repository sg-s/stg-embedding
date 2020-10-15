% callback function used in manual clustering and labeling
% plots PD and LP spikes from the raw data
function plotSpikes(ax, data)

data = data';
data = reshape(data,length(data)/2,2);


cla(ax)
hold(ax,'on')

a = min(data(:));
data = data - a;




neurolib.raster(ax,data(:,1),'yoffset',0,'deltat',1,'center',false,'Color','k')	
neurolib.raster(ax,data(:,2),'yoffset',1,'deltat',1,'center',false,'Color','r')	

set(ax,'YLim',[0 2],'XLim',[-.1 20.1],'YTickLabel',{'LP','PD'},'YTick',[.5 1.5])

% write current point to workspace
C = evalin('base','m.CurrentPoint');
AB = [1; 1];
try
	AB = evalin('base','AB');
catch
end


AB = [AB(2); C];
assignin('base','AB',AB);
