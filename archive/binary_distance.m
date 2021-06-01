% test script that embeds base data in a unsupervised fashion
% using binary distance functions 





% compute 2nd order ISIs
PD_PD2 = embedding.NthOrderISIs(basedata.PD);
LP_LP2 = embedding.NthOrderISIs(basedata.LP);



% pad ISIs to account for truncated segments
[basedata.PD_PD, basedata.LP_LP] = embedding.padISIsToCompensateForTerminalSilence(basedata.PD,basedata.LP,basedata.PD_PD,basedata.LP_LP);

[PD_PD2, LP_LP2] = embedding.padISIsToCompensateForTerminalSilence(basedata.PD,basedata.LP,PD_PD2,LP_LP2);


% compute spike phases
[~,~,PD_LP,LP_PD] = embedding.spikePhase(basedata);


% measure the distances using the C++ accelerated distance function code 
DistanceMatrix = embedding.ISIDistance(basedata.LP_LP) + embedding.ISIDistance(basedata.PD_PD);

 
% compute distances for phases
PhaseDistance = embedding.ISIDistance(LP_PD, linspace(0,1,30)) + embedding.ISIDistance(PD_LP, linspace(0,1,30));

% measure 2nd order ISI ratios
PD_ratios = (max(PD_PD2,[],2)./max(basedata.PD_PD,[],2));
LP_ratios = (max(LP_LP2,[],2)./max(basedata.LP_LP,[],2));

% clean up ratios
PD_ratios(PD_ratios<1.3) = 1;
LP_ratios(LP_ratios<1.3) = 1;

% create a distance matrix for the 2nd order ISI 
SecondOrderDistances = squareform(pdist(PD_ratios) + pdist(LP_ratios));
SecondOrderDistances(isnan(SecondOrderDistances)) = 0;


% another distance matrix for the firing rates of PD and LP
FiringRatesMatrix = pdist(sum(~isnan(basedata.PD),2)/20) + pdist(sum(~isnan(basedata.LP),2)/20);
FiringRatesMatrix = squareform(FiringRatesMatrix);


save('distances.mat','SecondOrderDistances','DistanceMatrix','PhaseDistance')


MaxISIDistance = squareform(pdist(nanmax(basedata.PD_PD,[],2)) + pdist(nanmax(basedata.LP_LP,[],2)));
MaxISIDistance(isnan(MaxISIDistance)) = 0;

% magic numbers and hyperparameters
Bias.ISI2 = 20;
Bias.Phase = 10;
Bias.FiringRates = 1;
Bias.MaxISI = 10;

u = umap;
u.n_neighbors = 75;
u.negative_sample_rate = 25;
u.metric = 'precomputed';
R = u.fit(DistanceMatrix + Bias.ISI2*SecondOrderDistances + Bias.Phase*PhaseDistance + Bias.FiringRates*FiringRatesMatrix + Bias.MaxISI*MaxISIDistance);