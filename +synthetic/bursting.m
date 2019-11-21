% this helper function make synthetic data that looks
% like spiketimes from a bursting neuron

function spiketimes = bursting(BurstPeriod,NSpikesPerBurst,DutyCycle,SpiketimeJitter, BinSize)


NS = NSpikesPerBurst(randi(length(NSpikesPerBurst),1));
spiketimes = linspace(0,BurstPeriod*DutyCycle,NS);

spiketimes = repmat(spiketimes,100,1);
for j = 1:100
	spiketimes(j,:) = spiketimes(j,:) + BurstPeriod*j;
end

spiketimes = spiketimes';
spiketimes = spiketimes(:);
spiketimes = spiketimes + randn(length(spiketimes),1)*SpiketimeJitter*mean(diff(spiketimes));

spiketimes = spiketimes - spiketimes(1);
spiketimes(spiketimes>BinSize) = [];