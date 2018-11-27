

load('0d7785751d242bc1bc7ce8bd17d7ea35.mat')

% convert spiketimes into ms
all_spiketimes = all_spikes; clear all_spikes
all_spiketimes = floor(all_spiketimes*50e-3);

all_spikes = sparse(zeros(4e3,3));
for i = 1:3
	all_spikes(nonnans(all_spiketimes(:,i)),i) = 1;
end

all_temperature = vectorise(repmat(all_temp,200e3,1));
all_time = (1:length(all_temperature))*1e-3;

p = panopticon;
p.spikes = all_spikes;
p.label_info = all_temperature;
p.time = all_time;

p.window_size = 20; % seconds 
p.step_size = 1;
p.project;


figure('outerposition',[300 300 1002 901],'PaperUnits','points','PaperSize',[1002 901]); hold on
idx = 1;
for i = 1:3
	for j = 1:3
		subplot(3,3,idx); hold on
		idx = idx + 1;
		L = p.projected_data(i,j).label_info;
		plot(p.projected_data(i,j).time,p.projected_data(i,j).isis,'k.','MarkerSize',3)
		set(gca,'YScale','log','YLim',[1e-3 10],'XLim',[min(p.time) max(p.time)])
		drawnow


	end
end


prettyFig();

if being_published
	snapnow
	delete(gcf)
end