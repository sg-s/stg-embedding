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

% note that cross ISIs can be arbitrarily small, and we want our distance
% function to work with that 


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



		% show PD isis
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
			end
		end

	end

	figlib.pretty

end

close all
drawnow


% now we measure distances for all the different ISI distance metrics

fn = {'PD_PD','LP_LP','PD_LP','LP_PD'};

if exist('all_distances.mat','file') == 2
	load('all_distances.mat','D')
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


% Now we look at the actual matrices

figure('outerposition',[300 300 1200 1201],'PaperUnits','points','PaperSize',[1200 1201]); hold on

idx = 1;
for Variant = 1:4
	for i = 1:length(fn)
		subplot(4,4,idx); idx = idx + 1;

		imagesc(mathlib.symmetrize(D(Variant).(fn{i})(1:10:end,1:10:end)))
		caxis([0 5])

		if Variant == 1
			title(fn{i},'interpreter','none')
		end

		if i == 1
			ylabel(['Variant' mat2str(Variant)])
		end
		axis square
		set(gca,'XTick',[],'YTick',[])

	end

end

figlib.pretty


%%
% Now we embed the data using t-SNE and look at how the data are distributed


clear R X Y
for Variant = 1:2
	embed_distance = 0*D(1).PD_PD;
	for i = 1:length(fn)
		embed_distance = embed_distance + D(Variant).(fn{i});
	end
	embed_distance = mathlib.symmetrize(embed_distance);

	embed_distance = sum(embed_distance,3);

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
figure('outerposition',[300 300 1801 601],'PaperUnits','points','PaperSize',[1801 601]); hold on

c = lines(9);
c(8,:) = [0 0 0];
c(9,:) = [1 0 0];

for Variant = 1:2

	subplot(1,2,Variant); hold on

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


end

figlib.pretty()



% effect of perplexity (only Variant 1)
all_perplexity = linspace(20,200,10);
Variant = 1;

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
