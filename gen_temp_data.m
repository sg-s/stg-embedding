

p = gcp;

% small script to generate networks
for i = p.NumWorkers:-1:1
	worker(i) = parfeval(p,@syntheticData.generateInfiniteData,0);
end