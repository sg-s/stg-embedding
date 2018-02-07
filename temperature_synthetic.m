
pHeader;


%% Embedding of synthetic temperature data
% In this document, I work with spiketimes from a single network with 10 different q_10 values as it goes through a temperature ramp. I then embed these spike times, and see if my method can do a good job capturing the variability in the responses of the neuron as it is perturbed by temperature. 


% load the data
dm = dataManager;
load(dm.getPath('e00f57071f88b4f38d45af97f5fb5e66'))

%% Raw data
% The following figure shows what the raw data looks like -- each set of three rasters are spike times from AB, LP and PY. Temperature increases as you go down, as shown from the colorbar. Initially, the rhythm is triphasic, but breaks down eventually. 


% show the spike times
figure('outerposition',[0 0 591 901],'PaperUnits','points','PaperSize',[591 901]); hold on
idx = 966;
for i = 1:10
	raster(AB_spikes(:,idx),LP_spikes(:,idx),PY_spikes(:,idx),'deltat',1e-3,'yoffset',(i-1)*4)
	idx = idx - 100;
end
set(gca,'YTick',[])
xlabel('Time (s)')

c = colorbar;
caxis([min(temperature) max(temperature)]);
c.YDir = 'reverse';

prettyFig('plw',.5)

if being_published	
	snapnow	
	delete(gcf)
end


% project the data using panopticon 

%% Projection into high dimensional space
% Now, I project each time trace into a high-dimensional point that captures information about the oscillation of each neuron and the phase relationships between them. I can now plot how period, etc. vary with temperature. 


p = panopticon;
p.spiketimes = {AB_spikes, LP_spikes, PY_spikes};

p.project;

data_groups = vectorise(repmat(1:10,966,1));

figure('outerposition',[0 0 1200 900],'PaperUnits','points','PaperSize',[1200 900]); hold on

subplot(3,3,1); hold on
for i = 1:10
	plot(temperature(data_groups == i),p.X(data_groups==i,1),'.')
end
set(gca,'YLim',[0 5000])
xlabel('Temperature (°C)')
ylabel('ABPD period (ms)')

subplot(3,3,2); hold on
for i = 1:10
	plot(temperature(data_groups == i),p.X(data_groups==i,19),'.')
end
set(gca,'YLim',[0 1])
xlabel('Temperature (°C)')
ylabel('AB-LP phase')

subplot(3,3,3); hold on
for i = 1:10
	plot(temperature(data_groups == i),p.X(data_groups==i,21),'.')
end
set(gca,'YLim',[0 1])
xlabel('Temperature (°C)')
ylabel('AB-PY phase')

subplot(3,3,4); hold on
for i = 1:10
	plot(temperature(data_groups == i),p.X(data_groups==i,3),'.')
end
set(gca,'YLim',[0 1])
xlabel('Temperature (°C)')
ylabel('Duty cycle AB')


subplot(3,3,5); hold on
for i = 1:10
	plot(temperature(data_groups == i),p.X(data_groups==i,9),'.')
end
set(gca,'YLim',[0 1])
xlabel('Temperature (°C)')
ylabel('Duty cycle LP')


subplot(3,3,6); hold on
for i = 1:10
	plot(temperature(data_groups == i),p.X(data_groups==i,15),'.')
end
set(gca,'YLim',[0 1])
xlabel('Temperature (°C)')
ylabel('Duty cycle PY')

subplot(3,3,7); hold on
for i = 1:10
	plot(temperature(data_groups == i),p.X(data_groups==i,5),'.')
end
set(gca,'YLim',[0 30])
xlabel('Temperature (°C)')
ylabel('# spikes ABPD')


subplot(3,3,8); hold on
for i = 1:10
	plot(temperature(data_groups == i),p.X(data_groups==i,11),'.')
end
set(gca,'YLim',[0 30])
xlabel('Temperature (°C)')
ylabel('# spikes LP')


subplot(3,3,9); hold on
for i = 1:10
	plot(temperature(data_groups == i),p.X(data_groups==i,17),'.')
end
set(gca,'YLim',[0 30])
xlabel('Temperature (°C)')
ylabel('# spikes PY')

prettyFig();

if being_published
	snapnow
	delete(gcf)
end



%% Version Info
%
pFooter;


