
pHeader;


%%
% In this document, I take some data from Sara Haddad where she recorded from
% the pyloric circuit with temperature ramps and neuromodulators and see if I can 
% represent the activity of the network in a nice way

data_dir = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding/828_128';

data = crabsort.consolidate('nerves',{'pdn','lpn'},'neurons',{'LP','PD'},'data_dir',data_dir);

data_dir = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding/828_042';

data = [data crabsort.consolidate('nerves',{'pdn','lpn'},'neurons',{'LP','PD'},'data_dir',data_dir)];


% first, show all the raster (examples)
all_temp = nonnans(unique([data.temperature]));
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
		ylabel([oval(this_temp) 'C'])
	case 2
		show_this = find([data.decentralized] == true & [data.temperature] == this_temp & [data.proctolin] == 0,1,'first');
	case 0
		show_this = find([data.decentralized] == true & [data.temperature] == this_temp & [data.proctolin] > 0,1,'first');
	end

	if ~isempty(show_this)
		mtools.neuro.raster(data(show_this).PD,data(show_this).LP,'deltat',1);
	end
	set(gca,'XLim',[0 5],'YTick',[],'XTick',[],'XColor','w')

end

prettyFig()

if being_published	
	snapnow	
	delete(gcf)
end


%% ISI representation
% 

data = computeISIs(data,{'PD','LP'});

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
		ylabel([oval(this_temp) 'C'])
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



%% How to reproduce this document
% 

%%
% First, get the code: 

pFooter;

%%
% Then, run this script:

disp(mfilename)


