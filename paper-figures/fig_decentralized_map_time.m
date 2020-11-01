% this figure shows the map, and then color codes the points
% by time since decentralized


init()



time_since_decentralization = analysis.timeSinceDecentralization(alldata);
all_preps = unique(decdata.experiment_idx);


figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

display.plotBackgroundLabels(gca,alldata, R)


time_since_decentralization(time_since_decentralization<0) = NaN;
time_since_decentralization(time_since_decentralization>1800) = NaN;

X = R(:,1)+randn(length(R),1)/10;
Y = R(:,2)+randn(length(R),1)/10;
rm_this = isnan(time_since_decentralization);
X = X(~rm_this);
Y = Y(~rm_this);
time_since_decentralization(rm_this) = [];

SZ = time_since_decentralization;
SZ = SZ - min(SZ);
SZ = SZ/max(SZ);
SZ = SZ*480;
SZ = SZ + 20;
sh = scatter(X,Y,SZ,time_since_decentralization,'Marker','.');

colormap jet

ch = colorbar;
axis square

title(ch,{'Time since ',' decentralization (s)'})
ch.Position = [.88 .1 .01 .4];

axis off
figlib.pretty()


% cleanup
figlib.saveall('Location',display.saveHere)


init()