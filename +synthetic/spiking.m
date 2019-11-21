function spiketimes = spiking(f, BinSize, Jitter)


spiketimes = linspace(0,BinSize,floor(BinSize*f));
spiketimes = spiketimes(:) + randn(length(spiketimes),1)*mean(diff(spiketimes))*Jitter;
spiketimes(spiketimes>BinSize) = spiketimes(spiketimes>BinSize) - BinSize;
spiketimes = abs(spiketimes);

