% test function that converts spike trains
% into mean and variances for each ISI order
function M = meanVarianceISIs(alldata)

[p, VectorisedPercentiles] = sourcedata.spikes2percentiles(alldata,'ISIorders',[1:10],'PercentileVec',linspace(0,100,6));

M = [p.PD_stdISI  p.LP_stdISI p.PD_PD  p.LP_LP p.PD_LP p.LP_PD];


M(isnan(M)) = -10;
M(isinf(M)) = -10;