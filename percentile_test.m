% in this script
% we see if we can use ISI percentiles to make a vectorized data
% matrix with a few tweakable huperparmaeters and simply umap those



% compute 2nd order ISIs
PD_PD2 = embedding.NthOrderISIs(basedata.PD);
LP_LP2 = embedding.NthOrderISIs(basedata.LP);



% measure 2nd order ISI ratios
% need to do this before we pad ISIs to account for truncated
% segments 
PD_ratios = (max(PD_PD2,[],2)./max(basedata.PD_PD,[],2));
LP_ratios = (max(LP_LP2,[],2)./max(basedata.LP_LP,[],2));

% clean up ratios
PD_ratios(PD_ratios<1.3) = 1;
LP_ratios(LP_ratios<1.3) = 1;



% compute spike phases
if ~exist('PD_LP','var')
	[~,~,PD_LP,LP_PD] = embedding.spikePhase(basedata);
end



% pad ISIs to account for truncated segments
[basedata.PD_PD, basedata.LP_LP] = embedding.padISIsToCompensateForTerminalSilence(basedata.PD,basedata.LP,basedata.PD_PD,basedata.LP_LP);








Percentiles = [0 5 10 50 90 95 100];
P_ISIs = [prctile(basedata.PD_PD,Percentiles,2) prctile(basedata.LP_LP,Percentiles,2)];
P_Phases = [prctile(PD_LP,Percentiles,2) prctile(LP_PD,Percentiles,2)];


% choose missing values intelligently 
P_ISIs(isnan(P_ISIs)) = 20;
P_Phases(isnan(P_Phases)) = 1;
PD_ratios(isnan(PD_ratios)) = 2;
LP_ratios(isnan(LP_ratios)) = 2;

% normalize columns. This is because it doesn't make 
% any sense for the small ISIs, or the small phases to be 
% "closer" than the larger ones. 
P_ISIs = normalize(P_ISIs);
P_Phases = normalize(P_Phases);

% exxagerate the biggest ISIs because they matter more
P_ISIs(:,length(Percentiles):length(Percentiles):end) = P_ISIs(:,length(Percentiles):length(Percentiles):end)*20;

% exxagerate the smallest phases because we care about that too
% this should help with aberrant spikes
P_Phases(:,1:length(Percentiles):end) = P_Phases(:,1:length(Percentiles):end)*1;


% compute longest silence. this should help with separating interrupted bursting
longest_silence = embedding.longestSilence(basedata);

FiringRates = embedding.firingRates(basedata);

% magic numbers and hyperparameters
Bias.ISI2 = 50;
Bias.Phase = 10;
Bias.LongestSilence = 20;
Bias.f = 1;

VectorizedData = 	[P_ISIs ...
					Bias.Phase*P_Phases ...
					Bias.ISI2*PD_ratios ...
					Bias.ISI2*LP_ratios ...
					Bias.LongestSilence*longest_silence ...
					Bias.f*FiringRates];




u = umap;
u.n_neighbors = 75;
u.negative_sample_rate = 25;
R = u.fit(VectorizedData);