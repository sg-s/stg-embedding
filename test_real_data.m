
pHeader;

%% Embedding of STG dynamics during temperature perturbations 
% In this document, I explore methods to embed the dynamics of the pyloric rhythm during temperature perturbation. This data comes from Tang & Rinberg (776_090). 


dm = dataManager;

path_name = fileparts(dm.getPath('8e1282abfeb55567ab10bb74db2514e4'));
c = crabsort(false); c.path_name = path_name;

allfiles = dir(joinPath(path_name,'*.abf'));


% get the total length of the vector 
% we need to create by scanning all the files

N = 0;

for i = 1:length(allfiles)

	c.reset;
	c.file_name = allfiles(i).name;
	c.loadFile;

	N = N + length(c.time);

end

PD_spikes = sparse(N,1);
LP_spikes = sparse(N,1);
PY_spikes = sparse(N,1);

temperature = NaN(N,1);

offset = 0;

for i = 1:length(allfiles)

	c.reset;
	c.file_name = allfiles(i).name;
	c.loadFile;

	PD = c.spikes.pdn.PD + offset;
	PD_spikes(PD) = 1;

	LP = c.spikes.lpn.LP + offset;
	LP_spikes(LP) = 1;

	PY = c.spikes.pyn.PY + offset;
	PY_spikes(PY) = 1;


	temperature(offset + 1:offset + length(c.raw_data)) = c.raw_data(:,2);

	offset =  offset + length(c.time);
end


time = (1:length(temperature))*c.dt;

%% 
% In the following figure, I plot the temperature data set over the entire dataset to get an idea of what these guys were doing. 



figure('outerposition',[0 0 1000 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
plot(time(1:100:end),temperature(1:100:end),'k.')
xlabel('Time (s)')
ylabel('Temperature (C)')
prettyFig();

if being_published
	snapnow
	delete(gcf)
end

% stagger the data so we can quickly embed them
step_size = find(time < 5, 1, 'last');
bin_size = find(time<20,1,'last');

PD = stagger(PD_spikes,bin_size,step_size);
LP = stagger(LP_spikes,bin_size,step_size);
PY = stagger(PY_spikes,bin_size,step_size);

temperature = stagger(temperature,bin_size,step_size);
temperature = mean(temperature);

time = linspace(0,max(time),length(temperature));
dt = 1.9500e-04;

% show the spike times


figure('outerposition',[0 0 1444 901],'PaperUnits','points','PaperSize',[1444 901]); hold on

ramp_starts = [1 3369 4869];
ramp_stops = [3319 4838 5691];

example_temp = linspace(11,30,8);

L = {};
for i = 1:length(example_temp)
	L{i} = oval(example_temp(i));
end

for ri = 1:length(ramp_starts)

	subplot(1,length(ramp_starts),ri); hold on

	set(gca,'YLim',[0 length(example_temp)*4],'YTick',[1.5:4:length(example_temp)*4],'YTickLabel',L)

	if ri == 1
		ylabel('Temperature (C)')
	end
	xlabel('Time (s)')

	% find some example points on the first ramp 
	a = find(time > ramp_starts(ri),1,'first');
	z = find(time > ramp_stops(ri),1,'first');
	these_temp = temperature;
	these_temp(1:a) = 0;
	these_temp(z+1:end) = 0;


	for i = 1:length(example_temp)

		[mv,idx] = min(abs(these_temp - example_temp(i)));
		if mv > .5
			continue
		end

		try
			raster(PD(:,idx),LP(:,idx),PY(:,idx),'deltat',dt,'yoffset',(i-1)*4)
		catch
		end
	end


	title(['Ramp ' oval(ri)])
end

prettyFig('plw',1,'lw',1);



if being_published	
	snapnow	
	delete(gcf)
end


% now embed it

p = panopticon;
p.Color = temperature;
p.spiketimes = {PD, LP, PY};
p.perplexity = 90;
p.project;
[R, C] = p.embed;


return

% make a new color scheme for the ramp # 

ramp_id = 0*temperature;

for i = 1:length(ramp_starts)

	idx = time > ramp_starts(i) & time < ramp_stops(i);
	ramp_id(idx) = i;
end



figure('outerposition',[0 0 901 901],'PaperUnits','points','PaperSize',[1e3+1 901]); hold on



c = lines(length(ramp_starts));

for i = 1:length(ramp_starts)
	idx = time > ramp_starts(i) & time < ramp_stops(i);
	scatter(R(1,idx),R(2,idx),128,'MarkerFaceColor',c(i,:),'MarkerFaceAlpha',.3,'MarkerEdgeColor',c(i,:),'MarkerEdgeAlpha',.1)
end

% also plot things that belong to no ramp
scatter(R(1,ramp_id == 0),R(2,ramp_id == 0),128,'MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',.3,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',.1)



%% Version Info
%
pFooter;

