% makes a figure showing the map, with sub-clusters labelled
% by how many preps they come form
% this allows us to find idiosyncratic clusters

clearvars -except data alldata p

R = double(alldata.R);

cats = categories(alldata.idx);
colors = display.colorscheme(cats);



figure('outerposition',[300 108 1301 1301],'PaperUnits','points','PaperSize',[1301 1301]); hold on

axis off
axis square

figlib.pretty('LineWidth',1)

sub_idx = embedding.watersegment(alldata);

% find dwelltimes by subcluster
n_preps = NaN*(1:max(sub_idx));
for i = 1:max(sub_idx)
	n_preps(i) =  length(unique(alldata.experiment_idx(sub_idx==i)));
end


fh = display.plotSubClusters(gca,alldata,.1,sub_idx);

FontSize = @(x) 14+ 20*(x - min(n_preps))/(max(n_preps) - min(n_preps));

for i = 1:max(sub_idx)
	mx = mean(R(sub_idx==i,1));
	my = mean(R(sub_idx==i,2));
	if n_preps(i) < 3
		text(mx,my,mat2str(n_preps(i),2),'FontSize',FontSize(n_preps(i)),'HorizontalAlignment','center','FontWeight','bold')
	else
		text(mx,my,mat2str(n_preps(i),2),'FontSize',FontSize(n_preps(i)),'HorizontalAlignment','center')
	end
end




clearvars -except data alldata p