
function generateData()


x = syntheticData.makeSTG();


% first, check if 
% 1) all neurons spike at 20C
% 2) all neurons are silent at 30C


x.temperature = 20;
x.integrate;


x.dt = 10;
x.output_type = 2;

data = x.integrate;

comp_names = x.find('compartment');

for i = 1:length(comp_names)
	if length(data.(comp_names{i}).spiketimes) == 0
		disp('At least one neuron is silent at 20C, aborting...')
		return
	end
end



x.temperature = 30;
x.integrate;
data = x.integrate;

for i = 1:length(comp_names)
	if length(data.(comp_names{i}).spiketimes) > 0
		disp('At least one neuron is NOT silent at 30C, aborting...')
		return
	end
end


disp('This one is interesting, will record spikes and save...')


all_temp = linspace(10,30,20);
T = 200e3; % 200 seconds


all_spikes = NaN(1e7,3);


spike_offset = 0;

for i = 1:length(all_temp)
	textbar(i,length(all_temp))
	x.t_end = T;
	x.temperature = all_temp(i);

	data = x.integrate;

	% add spikes
	for j = 1:3
		spike_times = spike_offset + data.(comp_names{j}).spiketimes;
		z = find(isnan(all_spikes(:,j)),1,'first');
		all_spikes(z:length(spike_times)+z-1,j) = spike_times;
	end

	spike_offset = spike_offset + round(x.t_end/x.sim_dt);

end


all_Q = x.get('*Q*');

filename = [GetMD5(all_Q) ,'.mat'];

save(filename,'all_Q','all_temp','all_spikes');