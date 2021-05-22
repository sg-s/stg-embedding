
% debug function to help figure out what's going on with
% metrics calculations


function debugMetrics(PD,LP,PD_burst_starts,LP_burst_starts,PD_burst_stops,LP_burst_stops)

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

neurolib.raster(LP,'deltat',1,'center',false,'Color',[.4 .4 .4])
neurolib.raster(PD,'deltat',1,'center',false,'yoffset',1,'Color','b')

plot(PD_burst_starts,PD_burst_starts*0+1.95,'go','MarkerFaceColor','g')
plot(PD_burst_stops,PD_burst_stops*0+1.95,'ro','MarkerFaceColor','r')

plot(LP_burst_starts,LP_burst_starts*0+.95,'go','MarkerFaceColor','g')
plot(LP_burst_stops,LP_burst_stops*0+.95,'ro','MarkerFaceColor','r')