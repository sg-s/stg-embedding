% helper function that makes irregular spike trians

function spiketimes =  irregular(f,BinSize)

n_spikes = round(f*BinSize);
spiketimes = sort(rand(n_spikes,1)*BinSize);