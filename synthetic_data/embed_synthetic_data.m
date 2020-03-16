%%
% In this script we make some synthetic data and embed this to understand how the emedding works


data = synthetic.makeData;


figure('outerposition',[300 300 1200 1111],'PaperUnits','points','PaperSize',[1200 1111]); hold on


cats = unique(data.experiment_idx);

for i = 1:9
	subplot(3,3,i); hold on

	plot_this = find(data.experiment_idx == cats(i));


	yoffset = 0;
	for idx = 3:5
		neurolib.raster(data.PD(:,plot_this(idx)),data.LP(:,plot_this(idx)),'split_rows',true,'deltat',1,'center',false,'yoffset',yoffset); 
		yoffset = yoffset + 3;
	end

	set(gca,'XLim',[0 5],'YLim',[0 8],'YTick',[])
	title(char(cats(i)))
	axis off

end

figlib.pretty



% convert to ISIs
H = structlib.md5hash(data);
if exist(['.' H '.cache'],'file')  == 2
	load(['.' H '.cache'],'data','-mat')
else
	data = thoth.computeISIs(data,{'PD','LP'});
	save(['.' H '.cache'],'data','-v7.3')
end


% impose a minimum ISI because ISIs that are too close together are silly
min_isi = 5e-3; % 5 ms
data.PD_PD(data.PD_PD<min_isi) = NaN;
data.LP_LP(data.LP_LP<min_isi) = NaN;



% colormap for clusters
c = lines(9);
c(8,:) = [0 0 0];
c(9,:) = [1 0 0];




% compute cumulative histograms for all ISIs
clear cdfs
types = {'PD_PD','LP_LP','LP_PD','PD_LP'};
nbins = 100;
bins = logspace(-3,1,nbins+1);
for i = 1:length(types)
	cdfs.(types{i}) = NaN(1e4,nbins);

	for j = 1:1e4
		temp = data.(types{i})(:,j);
		temp(isnan(temp)) = [];
		if isempty(temp)
			continue
		end

		cdfs.(types{i})(j,:) = histcounts(temp,bins,'Normalization','cdf');
	end

end



% naive form of earth-mover distance
D = zeros(1e4,1e4);
W = diff(bins);
tic
for isi = 1:4
	disp(types{isi})
	A = cdfs.(types{isi});
	D = D + thoth.EarthMoverDistance(A);
	
end
toc

figure, hold on
imagesc(D)

t = TSNE('implementation',TSNE.implementation.fitsne);
t.DistanceMatrix = D(1:end-1,1:end-1);
R = t.fit;



figure('outerposition',[300 300 700 600],'PaperUnits','points','PaperSize',[700 600]); hold on

clear l L
for i = 1:length(cats)-1
	plot_this = data.experiment_idx == cats(i);
	plot(R(plot_this,1),R(plot_this,2),'.','MarkerSize',10,'Color',c(i,:));
	l(i) = plot(NaN,NaN,'.','MarkerSize',40,'Color',c(i,:));
end

legend(l,corelib.categorical2cell(cats(1:end-1)),'Location','eastoutside')

axis off

figlib.pretty()







% note that cross ISIs can be arbitrarily small, and we want our distance
% function to work with that 

return

%%
% In the following figure, I plot all the ISIs for all the states so we can get a sense of how the ISI-based distance functions will work


for figidx = 1:3

	figure('outerposition',[300 300 1200 1111],'PaperUnits','points','PaperSize',[1200 1111]); hold on


	things_to_show = {'PD_PD','LP_LP','PD_LP','LP_PD'};

	for i = 1:3

		this_cat = cats((figidx-1)*3+i);


		idx = i;

		subplot(5,3,idx); hold on

		% show the spike times

		plot_this = find(data.experiment_idx == this_cat);
		neurolib.raster(data.PD(:,plot_this(idx)),data.LP(:,plot_this(idx)),'split_rows',true,'deltat',1,'center',false); 
		title(char(this_cat))
		set(gca,'XLim',[0 5],'YLim',[0 2])
		axis off


		% show all isis
		for j = 1:4
			idx = idx + 3;
			subplot(5,3,idx); hold on

			isis = data.(things_to_show{j})(:,plot_this(1:10:end));
			time = repmat(1:size(isis,2),1e3,1);
			time = time(:);
			isis = isis(:);

			plot(time,isis,'k.')
			set(gca,'YScale','log','YLim',[1e-2 1e1])
			if i == 1
				ylabel(things_to_show{j},'interpreter','none')
			elseif i > 1
				set(gca,'YTick',[],'YTickLabel',{})
			end
			if j < 4
				set(gca,'XTick',[])
			end
		end
		

	end

	figlib.pretty

end



% Now I discretize the ISIs into ISI histograms
fn = {'PD_PD','LP_LP','PD_LP','LP_PD'};

n_bins = 30;
isi_bin_edges = logspace(-2,log10(5),n_bins+1);
binned_isis = zeros(n_bins,size(data.PD,2),4);
bin_centers = isi_bin_edges(1:end-1)+diff(isi_bin_edges)/2;
for i = 1:4
	these_isis = data.(fn{i});
    for j = 1:size(these_isis,2)
        binned_isis(:,j,i) = histcounts(these_isis(:,j),isi_bin_edges);
        %binned_isis(:,j,i) = bin_centers(:).*binned_isis(:,j,i);
        % normalize
        binned_isis(:,j,i) =  binned_isis(:,j,i)/sum( binned_isis(:,j,i));
    end
end

% reshape
temp = zeros(n_bins*4,size(data.PD,2));
for i = 1:4
    temp(n_bins*(i-1)+1:n_bins*i,:) = binned_isis(:,:,i);
end
binned_isis = temp;
binned_isis(isnan(binned_isis)) = 0;




% clustering on binned ISIs



figure('outerposition',[300 300 1801 600],'PaperUnits','points','PaperSize',[1801 600]); hold on


% simple clustering on binned_isis
subplot(1,3,1); hold on
idx = clusterdata(binned_isis','Maxclust',9);
stairs(linspace(1,9,9),'r-')
plot(linspace(1,9,1e4),idx,'k.')
xlabel('True cluster ID')
ylabel('Inferred cluster ID')
set(gca,'XLim',[0 10],'YLim',[0 10])
for i = 1:9
	plotlib.vertline(i,'k:');
end
title('Hierarchical clustering')

% k-means
subplot(1,3,2); hold on
idx = kmeans(binned_isis',9);
stairs(linspace(1,9,9),'r-')
plot(linspace(1,9,1e4),idx,'k.')
xlabel('True cluster ID')
ylabel('Inferred cluster ID')
set(gca,'XLim',[0 10],'YLim',[0 10])
for i = 1:9
	plotlib.vertline(i,'k:');
end
title('k-means')

subplot(1,3,3); hold on
idx = clusterlib.densityPeaks(binned_isis,'NClusters',9);
stairs(linspace(1,9,9),'r-')
plot(linspace(1,9,1e4),idx,'k.')
xlabel('True cluster ID')
ylabel('Inferred cluster ID')
set(gca,'XLim',[0 10],'YLim',[0 10])
for i = 1:9
	plotlib.vertline(i,'k:');
end
title('density peaks')

figlib.pretty()




% embedding of binned ISIs

% PCA
[coeff,score,latent,tsquared,explained,mu] = pca(binned_isis);

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
subplot(2,2,1); hold on
plot(cumsum(explained),'k')
xlabel('# components')
ylabel('Fraction explained')
grid on
set(gca,'YLim',[0 100])
subplot(2,2,2); hold on


clear l L
for i = 1:length(cats)-1
	plot_this = data.experiment_idx == cats(i);
	plot(coeff(plot_this,1),coeff(plot_this,2),'.','MarkerSize',10,'Color',c(i,:));
	l(i) = plot(NaN,NaN,'.','MarkerSize',40,'Color',c(i,:));
end

legend(l,corelib.categorical2cell(cats(1:end-1)),'Location','eastoutside')

axis off
axis square


for i = 1:3
	subplot(2,3,i+3); hold on
	plot(score(:,i),'k')
	title(['PC' strlib.oval(i)])
	axis off
end


figlib.pretty()



% NMF

[W,H] = nnmf(binned_isis,9);
idx = kmeans(H',9);

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on


subplot(1,2,1); hold on
imagesc(W)
axis xy
axis off

subplot(1,2,2); hold on
plot(linspace(1,9,1e4),idx,'k.')
xlabel('True cluster ID')
ylabel('Inferred cluster ID')
plotlib.drawDiag();
figlib.pretty()


% t-SNE on the binned ISI histograms
t = TSNE;
t.n_iter = 500;
t.implementation = TSNE.implementation.vandermaaten;
t.raw_data = binned_isis;
R = t.fit;


figure('outerposition',[300 300 700 600],'PaperUnits','points','PaperSize',[700 600]); hold on

clear l L
for i = 1:length(cats)-1
	plot_this = data.experiment_idx == cats(i);
	plot(R(plot_this,1),R(plot_this,2),'.','MarkerSize',10,'Color',c(i,:));
	l(i) = plot(NaN,NaN,'.','MarkerSize',40,'Color',c(i,:));
end

legend(l,corelib.categorical2cell(cats(1:end-1)),'Location','eastoutside')

axis off

figlib.pretty()







% now we measure distances for all the different ISI distance metrics



if exist('all_distances.mat','file') == 2
	if ~exist('D','var') 
		load('all_distances.mat','D')
	end
else

	D = struct;
	for Variant = 1:4
		disp(['Variant ' mat2str(Variant)])
		for i = 1:length(fn)
			disp(fn{i})
			D(Variant).(fn{i}) = neurolib.ISIDistance(data.(fn{i}),[],Variant);
		end
	end 

	save('all_distances.mat','D','-v7.3')
end

%%
% First, we show the distributions of the four variants and the four differne types of ISIs 

figure('outerposition',[300 300 1200 1111],'PaperUnits','points','PaperSize',[1200 1111]); hold on

bin_edges = logspace(-2,1,100);
bin_centers = bin_edges(1:end-1) + diff(bin_edges)/2;

L = {'1','2','3','4'};

for i = 1:length(fn)
	subplot(2,2,i); hold on
	for Variant = 1:4
		hy = histcounts(D(Variant).(fn{i})(:),bin_edges);
		plot(bin_centers,hy)
	end

	if i == 1
		legend(L)
	end

	title(fn{i},'interpreter','none')

	set(gca,'XScale','log','YScale','log','XLim',[bin_edges(1) bin_edges(end)])

end

figlib.pretty()


% Now we look at the actual matrices (just show variant 4)

figure('outerposition',[300 300 1200 1201],'PaperUnits','points','PaperSize',[1200 1201]); hold on

Variant = 4;

clear ax
for i = 1:length(fn)
	ax(i) = subplot(2,2,i); 

	imagesc(mathlib.symmetrize(D(Variant).(fn{i})(1:10:end,1:10:end)))
	caxis([0 5])


	title(fn{i},'interpreter','none')
	axis square
	axis off
	set(gca,'XTick',[],'YTick',[])
	caxis([0 2])

end

figlib.pretty



%%
% Now we embed the data using t-SNE and look at how the data are distributed


clear R X Y
for Variant = 4:-1:1
	embed_distance = 0*D(1).PD_PD;
	for i = 1:length(fn)
		embed_distance = embed_distance + D(Variant).(fn{i});
	end
	embed_distance = mathlib.symmetrize(embed_distance);

	% remove last element
	embed_distance = embed_distance(1:end-1,1:end-1);

	t = TSNE; 
	t.perplexity = 120;
	t.distance_matrix = embed_distance;
	t.n_iter  = 500;
	t.implementation = TSNE.implementation.vandermaaten;
	R = t.fit;
	X(:,Variant) = R(:,1);
	Y(:,Variant) = R(:,2);

end




% plot and colour by label
figure('outerposition',[300 300 1111 902],'PaperUnits','points','PaperSize',[1111 902]); hold on


clear ax
for Variant = 1:4

	ax(Variant) = subplot(2,2,Variant); hold on

	clear l L
	for i = 1:length(cats)-1
		plot_this = data.experiment_idx == cats(i);
		plot(X(plot_this,Variant),Y(plot_this,Variant),'.','MarkerSize',10,'Color',c(i,:));
		l(i) = plot(NaN,NaN,'.','MarkerSize',40,'Color',c(i,:));
	end
	if Variant == 2
		legend(l,corelib.categorical2cell(cats(1:end-1)),'Location','eastoutside')
	end
	axis off
	axis square
	title(['Variant ' strlib.oval(Variant)])


end

figlib.pretty()

ax(2).Position(3:4) = ax(1).Position(3:4);
axlib.move(ax,'left',.05)







% can we color dots by firing rate and burst period




C = zeros(1e4,3);
C(:,1) = data.burst_period;
C(:,1) = C(:,1) - nanmin(C(:,1));
C(:,1) = C(:,1)/nanmax(C(:,1));
C(isnan(C(:,1)),1) = 0;


C(:,3) = data.firing_rate;
C(:,3) = C(:,3) - nanmin(C(:,3));
C(:,3) = C(:,3) + .2*nanmax(C(:,3));
C(:,3) = C(:,3)/nanmax(C(:,3));
C(isnan(C(:,3)),3) = 0;

C(:,3) = 1 - C(:,3);

C(end,:) = [];

C(:,2) = .3;


figure('outerposition',[300 300 901 902],'PaperUnits','points','PaperSize',[901 902]); hold on
sh = scatter(X(:,Variant),Y(:,Variant),91,C,'filled','MarkerFaceAlpha',.4);
axis off
figlib.pretty







% effect of perplexity (only Variant 4)
all_perplexity = linspace(20,200,10);
Variant = 4;

clear R X Y
for i = length(all_perplexity):-1:1
	embed_distance = 0*D(1).PD_PD;
	for j = 1:length(fn)
		embed_distance = embed_distance + D(Variant).(fn{j});
	end
	embed_distance = mathlib.symmetrize(embed_distance);

	embed_distance = sum(embed_distance,3);

	t = TSNE; 
	t.perplexity = all_perplexity(i);
	t.distance_matrix = embed_distance;
	t.n_iter  = 500;
	t.implementation = TSNE.implementation.vandermaaten;
	R = t.fit;
	X(:,i) = R(:,1);
	Y(:,i) = R(:,2);

end

% plot all perplexities 

figure('outerposition',[300 300 1200 999],'PaperUnits','points','PaperSize',[1200 999]); hold on

clear ax

for i = 1:9

	ax(i) = subplot(3,3,i); hold on

	clear l L
	for j = 1:length(cats)-1
		plot_this = data.experiment_idx == cats(j);
		plot(X(plot_this,i),Y(plot_this,i),'.','MarkerSize',10,'Color',c(j,:));
		l(i) = plot(NaN,NaN,'.','MarkerSize',40,'Color',c(i,:));
	end
	axis off
	title(['perplexity = ' strlib.oval(all_perplexity(i))])
	axis square


end

figlib.pretty

for i = 1:9
	ax(i).Position([3 4]) = [.22 .22];
end




% Now we have the distance matrix, we will try to cluster directly on that. 



Variant = 1;
embed_distance = 0*D(1).PD_PD;
for j = 1:length(fn)
	embed_distance = embed_distance + D(Variant).(fn{j});
end
embed_distance = mathlib.symmetrize(embed_distance);

embed_distance = sum(embed_distance,3);

% heirarchical clustering on the distance matrix
Y = squareform(embed_distance,'tovector');
Z = linkage(Y);

idx = cluster(Z,'Maxclust',9);

figure('outerposition',[300 300 1201 600],'PaperUnits','points','PaperSize',[1201 600]); hold on
subplot(1,2,1); hold on
plot(linspace(1,9,1e4),idx,'k.')
xlabel('True cluster ID')
ylabel('Inferred cluster ID')
set(gca,'XLim',[0 10],'YLim',[0 10])
spacing = 8/9;
for i = 1:9
    plotlib.vertline((i*spacing) + 1,'k:');
end

title('Hierarchical clustering')


% density peaks on distance matrix
idx = clusterlib.densityPeaks(embed_distance,'Distance','precomputed','NClusters',9); 

subplot(1,2,2); hold on
plot(linspace(1,9,1e4),idx,'k.')
xlabel('True cluster ID')
ylabel('Inferred cluster ID')
set(gca,'XLim',[0 10],'YLim',[0 10])
spacing = 8/9;
for i = 1:9
    plotlib.vertline((i*spacing) + 1,'k:');
end

title('density Peaks clustering')

figlib.pretty()





% UMAP embedding of distance matrix
u = umap('metric','precomputed');
R = u.fit(embed_distance);



figure('outerposition',[300 300 700 600],'PaperUnits','points','PaperSize',[700 600]); hold on

clear l L
for i = 1:length(cats)-1
	plot_this = data.experiment_idx == cats(i);
	plot(R(plot_this,1),R(plot_this,2),'.','MarkerSize',10,'Color',c(i,:));
	l(i) = plot(NaN,NaN,'.','MarkerSize',40,'Color',c(i,:));
end

legend(l,corelib.categorical2cell(cats(1:end-1)),'Location','eastoutside')

axis off

figlib.pretty()
