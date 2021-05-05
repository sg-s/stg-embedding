% this function converts a given dataset into
% a giant matrix that contains the vecotrized
% representation of data using ISI percentiles
% October 2020

function VectorizedData = spikes2percentiles(data)

arguments
	data (1,1) embedding.DataStore 
end




% compute 2nd order ISIs
PD_PD2 = embedding.NthOrderISIs(data.PD);
LP_LP2 = embedding.NthOrderISIs(data.LP);



% measure 2nd order ISI ratios
% need to do this before we pad ISIs to account for truncated
% segments 
PD_ratios = (max(PD_PD2,[],2)./max(data.PD_PD,[],2));
LP_ratios = (max(LP_LP2,[],2)./max(data.LP_LP,[],2));


% also include a metric that accounts for differences in biggest and 2nd biggest bursts 
% TOD: this has a flaw if there are 2 bursts being skipped, it will not be detected
% 
temp = sort(data.PD_PD,2,'descend','MissingPlacement','last');
temp = temp(:,1)./temp(:,2);
temp(temp>2) = 2;
temp(isnan(temp)) = 2;
PD_ratios = [PD_ratios temp];

temp = sort(data.LP_LP,2,'descend','MissingPlacement','last');
temp = temp(:,1)./temp(:,2);
temp(temp>2) = 2;
temp(isnan(temp)) = 2;
LP_ratios = [LP_ratios temp];


% clean up ratios
PD_ratios(PD_ratios<1.3) = 1;
LP_ratios(LP_ratios<1.3) = 1;


% choose missing values intelligently 
PD_ratios(isnan(PD_ratios)) = 2;
LP_ratios(isnan(LP_ratios)) = 2;


PD_ratios = normalize(PD_ratios);
LP_ratios = normalize(LP_ratios);


% compute spike phases

try evalin('base','PD_LP;');
	PD_LP = evalin('base','PD_LP;');
	LP_PD = evalin('base','LP_PD;');
catch
	[~,~,PD_LP,LP_PD] = embedding.spikePhase(data);
	assignin('base','PD_LP',PD_LP);
	assignin('base','LP_PD',LP_PD);
end


% pad ISIs to account for truncated segments
[data.PD_PD, data.LP_LP] = embedding.padISIsToCompensateForTerminalSilence(data.PD,data.LP,data.PD_PD,data.LP_LP);




% normally [0:10:100];
Percentiles =  0:10:100;
P_ISIs = [prctile(data.PD_PD,Percentiles,2) prctile(data.LP_LP,Percentiles,2)];

P_ISIs(isnan(P_ISIs)) = 20;
P_ISIs = normalize(P_ISIs);

% exxagerate the last ISIs 
P_ISIs(:,length(Percentiles):length(Percentiles):end) = P_ISIs(:,length(Percentiles):length(Percentiles):end)*10;


P_Phases = [prctile(PD_LP,Percentiles,2) prctile(LP_PD,Percentiles,2)];
P_Phases(isnan(P_Phases)) = 1;
P_Phases = normalize(P_Phases);




% exxagerate the smallest phases because we care about that too
% this should help with aberrant spikes
P_Phases(:,1:length(Percentiles):end) = P_Phases(:,1:length(Percentiles):end)*10;


% compute longest silence. this should help with separating interrupted bursting
% longest_silence = longestSilence(data);
% longest_silence(longest_silence>3) = 3;
% longest_silence = normalize(longest_silence);

FiringRates = normalize(firingRates(data));


Burstiness = normalize(burstiness(data));

% magic numbers and hyperparameters
Bias.ISI2 = 5;  % 5
Bias.Phase = 1;   % 1
Bias.f = 5; % 5
Bias.Burstiness = 2;  % 2

VectorizedData = 	[P_ISIs ...
					Bias.Phase*P_Phases ...
					Bias.ISI2*PD_ratios ...
					Bias.ISI2*LP_ratios ...
					Bias.f*FiringRates...
					Bias.Burstiness*Burstiness];
