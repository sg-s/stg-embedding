
%%
% In this document, I take some data from Sara Haddad where she recorded from
% the pyloric circuit with temperature ramps and neuromodulators and see if I can 
% represent the activity of the network in a nice way


% specify data files to work with:
data_files = {'828_001_1',...
              '828_042',...
              '828_128',...
              '857_016',...
              '857_020_1',...
              '857_104',...
              '857_080'};

data_dir = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding/';

if ~exist('data','var')
	data = [];
	for i = 1:length(data_files)
		data = crabsort.merge(data,crabsort.consolidate('neurons',{'LP','PD'},'data_dir',[data_dir data_files{i}]));
	end
end

% first, show all the raster (examples)
all_temp = 11:4:31;
N = length(all_temp);

figure('outerposition',[300 300 1200 1000],'PaperUnits','points','PaperSize',[1200 1000]); hold on
for i = 1:N*3
	subplot(N,3,i); hold on

	if i == 1
		title('Intact prep')
	elseif i == 2
		title('Decentralized')
	elseif i == 3
		title('proctolin')
	end

	this_temp = all_temp(ceil(i/3));

	switch rem(i,3)
	case 1
		% centralized
		show_this = find([data.decentralized] == false & [data.temperature] == this_temp & [data.proctolin] == 0,1,'first');
		ylabel([strlib.oval(this_temp) 'C'])
	case 2
		show_this = find([data.decentralized] == true & [data.temperature] == this_temp & [data.proctolin] == 0,1,'first');
	case 0
		show_this = find([data.decentralized] == true & [data.temperature] == this_temp & [data.proctolin] > 0,1,'first');
	end

	if ~isempty(show_this)
		neurolib.raster(data(show_this).PD,data(show_this).LP,'deltat',1);
	end
	set(gca,'XLim',[0 5],'YTick',[],'XTick',[],'XColor','w')

end

figlib.pretty



%%
% Now we show all spikes from the control data at all temperatures

figure('outerposition',[300 300 700 1e3],'PaperUnits','points','PaperSize',[700 1e3]); hold on

idx= 0;
for i = 1:length(data)
	if data(i).decentralized == 0 && (isnan(data(i).oxotremorine) | data(i).oxotremorine == 0) && (isnan(data(i).proctolin) | data(i).proctolin == 0)
		neurolib.raster(data(i).PD,data(i).LP,'deltat',1,'yoffset',idx)
		idx = idx + 2;
	end
end

set(gca,'XLim',[0 150],'YLim',[0 idx]);
xlabel('Time (s)')
title('Control, all temperatures')

figlib.pretty

%%
% Now show all decentralized data

figure('outerposition',[300 300 700 1e3],'PaperUnits','points','PaperSize',[700 1e3]); hold on

idx= 0;
for i = 1:length(data)
	if data(i).decentralized == 1 && (isnan(data(i).oxotremorine) | data(i).oxotremorine == 0) && (isnan(data(i).proctolin) | data(i).proctolin == 0)
		neurolib.raster(data(i).PD,data(i).LP,'deltat',1,'yoffset',idx)
		idx = idx + 2;
	end
end

set(gca,'XLim',[0 150],'YLim',[0 idx]);
xlabel('Time (s)')
title('Decentralized, all temperatures')

figlib.pretty()

%%
% Now show all decentralized data with oxotremorine

figure('outerposition',[300 300 700 1e3],'PaperUnits','points','PaperSize',[700 1e3]); hold on

idx = 0;
for i = 1:length(data)
	if (~isnan(data(i).oxotremorine) & data(i).oxotremorine> 0) && (isnan(data(i).proctolin) | data(i).proctolin == 0)
		neurolib.raster(data(i).PD,data(i).LP,'deltat',1,'yoffset',idx)
		idx = idx + 2;
	end
end

set(gca,'XLim',[0 150],'YLim',[0 idx]);
xlabel('Time (s)')
title('oxotremorine, all temperatures')

figlib.pretty()

%%
% Now show all decentralized data with proctolin

figure('outerposition',[300 300 700 1e3],'PaperUnits','points','PaperSize',[700 1e3]); hold on

idx= 0;
for i = 1:length(data)
	if (~isnan(data(i).proctolin) & data(i).proctolin> 0) && (isnan(data(i).oxotremorine) | data(i).oxotremorine == 0)
		neurolib.raster(data(i).PD,data(i).LP,'deltat',1,'yoffset',idx)
		idx = idx + 2;
	end
end

set(gca,'XLim',[0 150],'YLim',[0 idx]);
xlabel('Time (s)')
title('Proctolin, all temperatures')

figlib.pretty()


%% ISI representation
% 




% compute ISIS
data = computeISIs(data,{'PD','LP'});



% bin all data
cdata = chunk(data,'neurons',{'LP','PD'});

cdata =  rmfield(cdata,'mask');


% convert into a giant matrix
mdata = matrixify(cdata,'neurons',{'LP','PD'});


% compute pairwise distances
if exist('combined_distance.mat','file') == 2
	load('combined_distance.mat','D')
	load('all_dist.mat')
else

	D_LP_LP = neurolib.ISIDistance( mdata.LP_LP');
	D_LP_PD = neurolib.ISIDistance( mdata.LP_PD');
	D_PD_PD = neurolib.ISIDistance( mdata.PD_PD');
	D_PD_LP = neurolib.ISIDistance( mdata.PD_LP');

	% % hot fix -- recompute distances when NaN
	% for i = 1:length(D_PD_LP)
	% 	corelib.textbar(i,length(D_PD_LP))
	% 	for j = i+1:length(D_PD_LP)
	% 		if isnan(D_PD_LP(j,i))
	% 			temp =  neurolib.ISIDistance(mdata.PD_LP([j i],:)');
	% 			D_PD_LP(j,i) = temp(2,1);
	% 		end
	% 	end
	% end

	save('all_dist.mat','D_LP_LP','D_LP_PD','D_PD_PD','D_PD_LP')
	D = D_PD_PD/mean(D_PD_PD(:)) + D_LP_LP/mean(D_LP_LP(:)) + D_LP_PD/mean(D_LP_PD(:)) + D_PD_LP/mean(D_PD_LP(:));

	%D = D_PD_PD/mean(D_PD_PD(:)) + D_LP_LP/mean(D_LP_LP(:));

	D = D + tril(D)';

	save('combined_distance.mat','D')
end



% use tsne to embed into 2D

SS = 1;
t = TSNE; t.distance_matrix = D(1:SS:end,1:SS:end);
t.perplexity = 100;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;

mdataSS = mdata;
fn = fieldnames(mdata);
for i = 1:length(fn)
	mdataSS.(fn{i}) = mdataSS.(fn{i})(1:SS:end,:);
end

figure('outerposition',[300 300 903 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

% colour by experiment
unique_exp = unique(mdataSS.experiment_idx);
subplot(2,2,1); hold on
plot(R(:,1),R(:,2),'k.')

for i = 1:length(unique_exp)
	plot(R(mdataSS.experiment_idx==unique_exp(i),1),R(mdataSS.experiment_idx==unique_exp(i),2),'.')
end

% colour by temperature
all_temp = 7:2:31;
subplot(2,2,2); hold on
plot(R(:,1),R(:,2),'.','Color',[.2 .2 .2])
c = parula(length(all_temp));
for i = 1:length(all_temp)
	plot(R(mdataSS.temperature==all_temp(i),1),R(mdataSS.temperature==all_temp(i),2),'.','Color',c(i,:),'MarkerSize',24)
end

% colour by centralized
subplot(2,2,3); hold on
plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerSize',32)
mdataSS.serotonin(isnan(mdataSS.serotonin)) = 0;
mdataSS.proctolin(isnan(mdataSS.proctolin)) = 0;
mdataSS.oxotremorine(isnan(mdataSS.oxotremorine)) = 0;

only_decentralized = mdataSS.decentralized == 1 & mdataSS.serotonin == 0 & mdataSS.proctolin == 0 & mdataSS.oxotremorine == 0;

plot(R(mdataSS.decentralized==0,1),R(mdataSS.decentralized==0,2),'g.','MarkerSize',10)
plot(R(only_decentralized,1),R(only_decentralized,2),'k.','MarkerSize',10)
plot(R(mdataSS.proctolin>0,1),R(mdataSS.proctolin>0,2),'b.','MarkerSize',10)
plot(R(mdataSS.serotonin>0,1),R(mdataSS.serotonin>0,2),'b.','MarkerSize',10)
plot(R(mdataSS.oxotremorine>0,1),R(mdataSS.oxotremorine>0,2),'r.','MarkerSize',10)
axis off

figlib.pretty



return

figure('outerposition',[300 300 1200 1000],'PaperUnits','points','PaperSize',[1200 1000]); hold on
clear ax
for i = 1:N*3
	ax(i) = subplot(N,3,i); hold on

	if i == 1
		title('Intact prep')
	elseif i == 2
		title('Decentralized')
	elseif i == 3
		title('proctolin')
	end

	this_temp = all_temp(ceil(i/3));

	switch rem(i,3)
	case 1
		% centralized
		show_this = find([data.decentralized] == false & [data.temperature] == this_temp & [data.proctolin] == 0,1,'first');
		ylabel([strlib.oval(this_temp) 'C'])
	case 2
		show_this = find([data.decentralized] == true & [data.temperature] == this_temp & [data.proctolin] == 0,1,'first');
	case 0
		show_this = find([data.decentralized] == true & [data.temperature] == this_temp & [data.proctolin] > 0,1,'first');
	end


	c = parula(4);
	opacity = .2;
	marker_size = 32;
	if ~isempty(show_this)
		% first show PD-PD isis
		scatter(data(show_this).PD(1:end-1),data(show_this).PD_PD,marker_size,'MarkerFaceColor',[c(1,:)],'MarkerFaceAlpha',opacity,'MarkerEdgeColor',c(1,:),'MarkerEdgeAlpha',opacity)

		% then show LP-LP isis
		scatter(data(show_this).LP(1:end-1),data(show_this).LP_LP,marker_size,'MarkerFaceColor',[c(2,:)],'MarkerFaceAlpha',opacity,'MarkerEdgeColor',c(2,:),'MarkerEdgeAlpha',opacity)

		% now the cross ISIS
		scatter(data(show_this).PD,data(show_this).PD_LP,marker_size,'MarkerFaceColor',[c(3,:)],'MarkerFaceAlpha',opacity,'MarkerEdgeColor',c(3,:),'MarkerEdgeAlpha',opacity)
		scatter(data(show_this).LP,data(show_this).LP_PD,marker_size,'MarkerFaceColor',['r'],'MarkerFaceAlpha',opacity,'MarkerEdgeColor','r','MarkerEdgeAlpha',opacity)
	end
	
	


end

prettyFig()

for i = 1:length(ax)
	if i == 22
		set(ax(i),'XLim',[0 20],'YScale','log','YLim',[1e-3 10],'YTick',[1e-3 1e-2 1e-1 1])
		xlabel(ax(i),'Time (s)')
	else
		set(ax(i),'XLim',[0 20],'YScale','log','YTick',[])
		set(ax(i),'XColor','w','XTick',[],'YLim',[1e-3 10])
	end
	
end

if being_published	
	snapnow	
	delete(gcf)
end



%%
% Now we compute all the pairwise distances of all 





%%
% Now we bin all the data in two ways: we bin into 10 second non-overlapping windows, and for those windows collapse time. Then, we bin the ISIs logarthimically, to obtain matrices (images) that represent the firing pattern in each window. 

n_bins = 30;
max_isi = 5;
min_isi = 3e-3;
binned_data = imageify(data,'neurons',{'PD','LP'},'n_bins',n_bins,'max_isi',max_isi,'min_isi',min_isi);
bin_edges = logspace(log10(min_isi), log10(max_isi),n_bins+1);
bin_centres = bin_edges(1:end-1)+diff(bin_edges)/2;

xtick = [1 10 19 30];

for i = length(xtick):-1:1
	XTickLabels{i} = strlib.oval(1e3*bin_centres(xtick(i)));
end

figure('outerposition',[300 300 800 1200],'PaperUnits','points','PaperSize',[800 1200]); hold on
subplot(1,4,1); hold on
imagesc(binned_data.M(1:n_bins,binned_data.decentralized==0)')
C = [linspace(1,0,100)' linspace(1,0,100)' ones(100,1)];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45)
xlabel('ISI (ms)')
box off



subplot(1,4,2); hold on
imagesc(binned_data.M(n_bins+1:n_bins*2,binned_data.decentralized==0)')
C = [linspace(1,0,100)' ones(100,1) linspace(1,0,100)' ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')
box off

subplot(1,4,3); hold on
imagesc(binned_data.M(2*n_bins+1:n_bins*3,binned_data.decentralized==0)')
C = [ ones(100,1) linspace(1,0,100)' linspace(1,0,100)' ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')
box off

ax = subplot(1,4,4); hold on
imagesc(binned_data.M(3*n_bins+1:n_bins*4,binned_data.decentralized==0)')
C = [ ones(100,1) linspace(1,0,100)' ones(100,1)  ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')
box off
prettyFig();
box(ax,'off')

suptitle('Control, all temperatures')

if being_published
	snapnow
	delete(gcf)
end

%%
% Now we show the decentralized data.


figure('outerposition',[300 300 800 1200],'PaperUnits','points','PaperSize',[800 1200]); hold on
subplot(1,4,1); hold on
imagesc(binned_data.M(1:n_bins,binned_data.decentralized==1)')
C = [linspace(1,0,100)' linspace(1,0,100)' ones(100,1)];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45)
xlabel('ISI (ms)')
box off

subplot(1,4,2); hold on
imagesc(binned_data.M(n_bins+1:n_bins*2,binned_data.decentralized==1)')
C = [linspace(1,0,100)' ones(100,1) linspace(1,0,100)' ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')
box off

subplot(1,4,3); hold on
imagesc(binned_data.M(2*n_bins+1:n_bins*3,binned_data.decentralized==1)')
C = [ ones(100,1) linspace(1,0,100)' linspace(1,0,100)' ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')
box off

ax = subplot(1,4,4); hold on
imagesc(binned_data.M(3*n_bins+1:n_bins*4,binned_data.decentralized==1)')
C = [ ones(100,1) linspace(1,0,100)' ones(100,1)  ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')


prettyFig();
box(ax,'off')
suptitle('Decentralized preps, all temperatures')

if being_published
	snapnow
	delete(gcf)
end

%%
% Now we show oxotremorine preps

figure('outerposition',[300 300 800 1200],'PaperUnits','points','PaperSize',[800 1200]); hold on
subplot(1,4,1); hold on
imagesc(binned_data.M(1:n_bins,binned_data.oxotremorine>0)')
C = [linspace(1,0,100)' linspace(1,0,100)' ones(100,1)];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45)
xlabel('ISI (ms)')
box off

subplot(1,4,2); hold on
imagesc(binned_data.M(n_bins+1:n_bins*2,binned_data.oxotremorine>0)')
C = [linspace(1,0,100)' ones(100,1) linspace(1,0,100)' ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')
box off

subplot(1,4,3); hold on
imagesc(binned_data.M(2*n_bins+1:n_bins*3,binned_data.oxotremorine>0)')
C = [ ones(100,1) linspace(1,0,100)' linspace(1,0,100)' ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')
box off

ax = subplot(1,4,4); hold on
imagesc(binned_data.M(3*n_bins+1:n_bins*4,binned_data.oxotremorine>0)')
C = [ ones(100,1) linspace(1,0,100)' ones(100,1)  ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')


prettyFig();
box(ax,'off')
suptitle('Decentralized+oxotremorine, all temperatures')

if being_published
	snapnow
	delete(gcf)
end

%%
% Now we show proctolin preps

figure('outerposition',[300 300 800 1200],'PaperUnits','points','PaperSize',[800 1200]); hold on
subplot(1,4,1); hold on
imagesc(binned_data.M(1:n_bins,binned_data.proctolin>0)')
C = [linspace(1,0,100)' linspace(1,0,100)' ones(100,1)];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45)
xlabel('ISI (ms)')
box off

subplot(1,4,2); hold on
imagesc(binned_data.M(n_bins+1:n_bins*2,binned_data.proctolin>0)')
C = [linspace(1,0,100)' ones(100,1) linspace(1,0,100)' ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')
box off

subplot(1,4,3); hold on
imagesc(binned_data.M(2*n_bins+1:n_bins*3,binned_data.proctolin>0)')
C = [ ones(100,1) linspace(1,0,100)' linspace(1,0,100)' ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')
box off

ax = subplot(1,4,4); hold on
imagesc(binned_data.M(3*n_bins+1:n_bins*4,binned_data.proctolin>0)')
C = [ ones(100,1) linspace(1,0,100)' ones(100,1)  ];
colormap(gca,C)
set(gca,'XTick',xtick,'XTickLabels',XTickLabels,'XTickLabelRotation',45,'YTick',[])
xlabel('ISI (ms)')


prettyFig();
box(ax,'off')
suptitle('Decentralized+proctolin, all temperatures')

if being_published
	snapnow
	delete(gcf)
end



%% How to reproduce this document
% 

%%
% First, get the code: 

pFooter;

%%
% Then, run this script:

disp(mfilename)


