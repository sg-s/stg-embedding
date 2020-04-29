% in this figure, we label sub-clusters by burst metrics

clearvars -except data alldata p

R = double(alldata.R);

cats = categories(alldata.idx);
colors = display.colorscheme(cats);



figure('outerposition',[300 108 1301 1301],'PaperUnits','points','PaperSize',[1301 1301]); hold on

axis off
axis square

figlib.pretty('LineWidth',1)

sub_idx = embedding.watersegment(alldata);



fh = display.plotSubClusters(gca,alldata,.1,sub_idx);

R2 = circshift(R,1,1);
u = R2(:,1)-R(:,1);
v = R2(:,2)-R(:,2);

stat_pts = alldata.idx == circshift(alldata.idx,-1);
u(~stat_pts) = 0;
v(~stat_pts) = 0;

SS  = 3;
%quiver(R(1:SS:end,1),R(1:SS:end,2),u(1:SS:end),v(1:SS:end),3,'Color',[.6 .6 .6])



return



clearvars -except data alldata p