% this script generates spike data
% using simulations that
% we can then play around with 

x = sim.makeSTG;

x.closed_loop = true;

all_temp = linspace(10,30,20);
T = 200e3; % 200 seconds


all_spikes = NaN(1e7,3);


spike_offset = 0;

for i = 1:length(all_temp)
	textbar(i,length(all_temp))
	x.t_end = T;
	x.temperature = all_temp(i);

	V = x.integrate;

	% add spikes
	for j = 1:3
		spike_times = spike_offset + xolotl.findNSpikeTimes(V(:,j),xolotl.findNSpikes(V(:,j)));
		z = find(isnan(all_spikes(:,j)),1,'first');
		all_spikes(z:length(spike_times)+z-1,j) = spike_times;
	end

	spike_offset = spike_offset + round(x.t_end/x.dt);

end

S=all_spikes;
for i = 1:3
	S(S(:,i)<(200e3/x.dt)*17,i) = NaN;
	S(S(:,i)>(200e3/x.dt)*19,i) = NaN;
end