
pHeader;

%%
% In this document, I look at some real data from Tang et al. where they record extracellualrly from pdn, pyn and lpn and allpy temperature ramps. 

% gather the data

% experiment ID is 776_090
dm = dataManager;
allfiles = dir([fileparts(dm.getPath('8e1282abfeb55567ab10bb74db2514e4')) filesep '*.abf']);

all_time = [];
all_spikes = [];
all_temperature = [];

for i = 1:length(allfiles)
	textbar(i,length(allfiles))
	
	c = crabsort(false);
	c.file_name = allfiles(i).name;
	c.path_name = allfiles(i).folder;
	c.loadFile;

	this_time = c.time;
	this_spikes = sparse(zeros(length(this_time),3));
	this_spikes(c.spikes.pdn.PD,1) = 1;
	this_spikes(c.spikes.lpn.LP,2) = 1;
	this_spikes(c.spikes.pyn.PY,3) = 1;

	temp_channel = find(cellfun(@(x) strcmp(x,'temperature'),c.common.data_channel_names));

	this_temp = c.raw_data(:,temp_channel);

	if isempty(all_time)
		offset = 0;
	else
		offset = max(all_time);
	end

	all_time = [all_time; this_time(:) + offset];
	all_spikes = [all_spikes; this_spikes];

	all_temperature = [all_temperature; this_temp(:)];

end


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
plot(all_time(1:100:end),all_temperature(1:100:end),'k')
xlabel('Time (s)')
ylabel('Temperature (C)')

prettyFig()


if being_published	
	snapnow	
	delete(gcf)
end

% show raster 
figure('outerposition',[300 300 801 901],'PaperUnits','points','PaperSize',[801 901]); hold on
dt = mean(diff(all_time));
show_temp = [11 15 18 23 27 30];
for i = 1:6
	subplot(6,1,i); hold on
	mtools.neuro.raster(all_spikes,'deltat',dt)
	a = find(all_temperature>show_temp(i),1,'first');
	z = a + 20e3;
	set(gca,'XLim',[all_time(a) all_time(z)],'YTick',[])
	ylabel(['T = ' oval(show_temp(i)) 'C'])

end
xlabel('Time (s)')

prettyFig('lw',1)


if being_published	
	snapnow	
	delete(gcf)
end

%%
% Now I compute ISIs in various windows for this entire dataset. 


p = panopticon;
p.spikes = all_spikes;
p.label_info = all_temperature;
p.time = all_time;
p.resample(1e-3);
p.window_size = 20; % seconds 
p.step_size = 1;
p.project;

return


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
idx = 1;
for i = 1:3
	for j = 1:3
		subplot(3,3,idx); hold on
		idx = idx + 1;
		L = p.projected_data(i,j).label_info;
		plot(p.projected_data(i,j).time,p.projected_data(i,j).isis,'k.','MarkerSize',3)
		set(gca,'YScale','log')
		drawnow

	end
end


%% How to reproduce this document
% 

%%
% First, get the code: 

pFooter;

%%
% Then, run this script:

disp(mfilename)


