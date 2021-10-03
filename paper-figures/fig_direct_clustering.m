

%%
% In this script we cluster the vectorizedData directly to check that the manual clustering using t-SNE isn't too nonsensical 



file_loc = fullfile('..','cache','cluster_data.mat');

if exist(file_loc,'file') == 2
	load(file_loc,'cluster_idx')
else
	cluster_idx = clusterdata(VectorizedData(1:10:end,:),'MaxClust',20,'SaveMemory','on','Metric','euclidean','Linkage','centroid');
	save(file_loc,'cluster_idx')
end



only_this = 1:10:size(VectorizedData,1);

file_loc = fullfile('..','cache','cutoff_data.mat');

if exist(file_loc,'file') == 2
	load(file_loc,'all_cutoff','n_clusters')
else
	all_cutoff = logspace(log10(1),log10(1.2),100);
	n_clusters = all_cutoff*0;


	for i = 1:length(all_cutoff)
		temp = clusterdata(VectorizedData(only_this,:),all_cutoff(i));
		n_clusters(i) = length(unique(temp));
	end
	save(file_loc,'all_cutoff','n_clusters')

end






figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(1,2,1); hold on

plot(all_cutoff,n_clusters/length(only_this),'ko')
xlabel('Cutoff')
ylabel('No. of clusters/No. of points')


subplot(1,2,2); hold on

C = colormaps.dcol(20);

for i = 1:20

	this = cluster_idx == i;
	plot(R(this,1),R(this,2),'.','Color',C(i,:));

end
xlabel('t-SNE 1')
ylabel('t-SNE 2')

figlib.pretty