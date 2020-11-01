% this function serves as a callback from clusterlib.manual
% to aid in clutering 
% and naming clusters and exploring data

function plotRaster(self, ax)



cla(ax)

neurolib.ISIraster(ax,self.RawData(:,self.CurrentPoint))