% attempts to report distances between two points in the embedding
% for diagnostic purposes

function probe(Bias, BinEdges)

arguments
	
	Bias (1,1) struct
	BinEdges (:,1) double = [logspace(-2,.5,29) 20];
end

% read A and B from workspace
AB = evalin('base','AB');
A = AB(1);
B = AB(2);


data = evalin('base','basedata');

disp([mat2str(A) '  vs.  ' mat2str(B)])

% measure distances
D = embedding.ISIDistance(data.LP_LP([A, B],:));
LP_LP = D(1,2);
disp(['LP_LP  :  ' mat2str(LP_LP,3)])

D = embedding.ISIDistance(data.PD_PD([A, B],:));
PD_PD = D(1,2);
disp(['PD_PD  :  ' mat2str(PD_PD,3)])


% delays
PD_LP = evalin('base','PD_LP');
D = embedding.ISIDistance(PD_LP([A, B],:));
PD_LP = D(1,2);
disp(['PD_LP  :  ' mat2str(PD_LP,3)])

LP_PD = evalin('base','LP_PD');
D = embedding.ISIDistance(LP_PD([A, B],:));
LP_PD = D(1,2);
disp(['LP_PD  :  ' mat2str(LP_PD,3)])




PD_ratios = evalin('base','PD_ratios');
PD2 = Bias.ISI2*pdist(PD_ratios([A,B],:));
disp(['PD_PD2  :  ' mat2str(PD2,3)])

LP_ratios = evalin('base','LP_ratios');
LP2 = Bias.ISI2*pdist(LP_ratios([A,B],:));
disp(['LP_LP2  :  ' mat2str(LP2,3)])

disp(['Total = ' mat2str(LP_LP + PD_PD + PD_LP + LP_PD + PD2 + LP2)])


% show aberrant spikes
PD_LP = evalin('base','PD_LP');
LP_PD = evalin('base','LP_PD');
figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
subplot(3,2,1); hold on
plot(PD_LP(A,:))
plot(PD_LP(B,:))
title('PD_LP')
set(gca,'YLim',[0 1])

subplot(3,2,2); hold on
plot(LP_PD(A,:))
plot(LP_PD(B,:))
title('LP_PD')
set(gca,'YLim',[0 1])

subplot(3,2,3); hold on
H = histcounts(data.PD_PD(A,:),BinEdges);
H = [H; histcounts(data.PD_PD(B,:),BinEdges)];
H(H>0)=  1;
colormap(flipud(hot))
title('PD PD')
imagesc(H)

subplot(3,2,4); hold on
H = histcounts(data.LP_LP(A,:),BinEdges);
H = [H; histcounts(data.LP_LP(B,:),BinEdges)];
H(H>0)=  1;
colormap(flipud(hot))
title('LP LP')
imagesc(H)


% show the rasters
subplot(3,2,5); hold on
PD = data.PD(A,:);
LP = data.LP(A,:);
offset = nanmin([PD(:); LP(:)]);
PD = PD - offset;
LP = LP - offset;
neurolib.raster(PD,'center',false,'deltat',1)
neurolib.raster(LP,'center',false,'deltat',1,'yoffset',1)
set(gca,'XLim',[0 20])


subplot(3,2,6); hold on
PD = data.PD(B,:);
LP = data.LP(B,:);
offset = nanmin([PD(:); LP(:)]);
PD = PD - offset;
LP = LP - offset;
neurolib.raster(PD,'center',false,'deltat',1)
neurolib.raster(LP,'center',false,'deltat',1,'yoffset',1)
set(gca,'XLim',[0 20])