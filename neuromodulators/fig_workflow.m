

figure('outerposition',[300 300 801 1001],'PaperUnits','points','PaperSize',[801 1001]); hold on


% raster
subplot(5,1,1); hold on
neurolib.raster(alldata.PD(1,:),'deltat',1,'center',false)
neurolib.raster(alldata.LP(1,:),'deltat',1,'center',false,'yoffset',1,'Color',c(2,:))
axis off


% ISIs
subplot(5,1,2); hold on
x = alldata.PD_PD(1,:);
x = x(~isnan(x));
plot(20+(1:length(x)),x,'.','MarkerSize',10)
offset = length(x) + 40;

x = alldata.LP_LP(1,:);
x = x(~isnan(x));
plot((1:length(x))+offset,x,'.','MarkerSize',10)
set(gca,'YScale','log','XColor','w')
ylabel('ISI (s)')
offset = offset + length(x) + 20;

spikes = alldata.PD(1,:);
spikes(isnan(spikes)) = [];
spikes2 = circshift(spikes,2);
isis = spikes - spikes2;
isis(isis<.01) = [];
plot((1:length(isis))+offset,isis,'k.','MarkerSize',10)
offset = offset + length(isis) + 20;

spikes = alldata.LP(1,:);
spikes(isnan(spikes)) = [];
spikes2 = circshift(spikes,2);
isis = spikes - spikes2;
isis(isis<.01) = [];
plot((1:length(isis))+offset,isis,'r.','MarkerSize',10)
offset = offset + length(isis) + 20;

x = alldata.PD_LP(1,:);
x = x(~isnan(x));
plot((1:length(x))+offset,x,'b.','MarkerSize',10)
offset = offset + length(x) + 20;

x = alldata.LP_PD(1,:);
x = x(~isnan(x));
plot((1:length(x))+offset,x,'m.','MarkerSize',10)
offset = offset + length(x) + 20;

set(gca,'XLim',[0 offset])


% percentiles
subplot(5,1,3); hold on
area(1:11,p.PD_PD(1,1:11))

area(3+(12:22),p.LP_LP(1,1:11))

area(6+(23:33),p.PD_PD(1,12:end),'FaceColor','k');

area(42:52,p.LP_LP(1,12:end),'FaceColor','r');

area(55:65,p.PD_LP(1,:),'FaceColor','b');

area(68:78,p.LP_PD(1,:),'FaceColor','m');

set(gca,'YScale','log','XTick',[])
ylabel('ISI (s)')



% all data in matrix
subplot(5,1,4:5); hold on
imagesc(real(log(VectorisedPercentiles)))
axis off


figlib.pretty()