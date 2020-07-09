% a new binary classifier

function [VectorisedPercentiles,M] = binaryClassifier(alldata)

DataSize = length(alldata.mask);


% clean up spikes -- remove first spike time from each set
offset = (nanmin([alldata.PD alldata.LP],[],2));
for i = 1:DataSize
	if ~isnan(offset(i))
		alldata.PD(i,:) = alldata.PD(i,:) - offset(i);
		alldata.LP(i,:) = alldata.LP(i,:) - offset(i);
	end
end


% compute 2nd order ISIs
neurons = {'PD','LP'};
for i = 1:length(neurons)


	alldata.([neurons{i} '_' neurons{i} '2']) = NaN(DataSize,1e3);

	for j = 1:DataSize
		spikes = alldata.(neurons{i})(j,:);

		% check if there is a large empty section
		maxisi = max(diff(spikes));
		if (20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes)))) > maxisi
			spikes(find(isnan(spikes),1,'first')) = max(spikes)+(20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes))));
		end


		spikes2 = circshift(spikes,2);

		isis = spikes-spikes2;
		isis(isis<0.001) = NaN;
		alldata.([neurons{i} '_' neurons{i} '2'])(j,:) = isis;

		
	end
end






% placeholders
M.PD_T_InRange = zeros(DataSize,1);
M.LP_T_InRange = zeros(DataSize,1);
M.PD_T_LT_Max = zeros(DataSize,1);
M.LP_T_LT_Max = zeros(DataSize,1);
M.PD_T_LT_2Max = zeros(DataSize,1);
M.LP_T_LT_2Max = zeros(DataSize,1);
M.PD_ACF_OK = zeros(DataSize,1);
M.LP_ACF_OK = zeros(DataSize,1);
M.LP_SingleSpike = zeros(DataSize,1);
M.PD_SingleSpike = zeros(DataSize,1);


% single spike filter
temp = nanmax(alldata.LP_LP2,[],2)./nanmax(alldata.LP_LP,[],2);
M.LP_SingleSpike(temp>1.2) = 1;
temp = nanmax(alldata.PD_PD2,[],2)./nanmax(alldata.PD_PD,[],2);
M.PD_SingleSpike(temp>1.2) = 1;




% compute dominant periods

isi_types = {'PD_PD','LP_LP'};
DomPeriods = {};
ACF_values = {};


for i = length(isi_types):-1:1

	disp(isi_types{i})

	neuron = isi_types{i};
	z = strfind(neuron,'_');
	neuron = neuron(1:z-1);


	isis = alldata.(isi_types{i});
	spikes = alldata.(neuron);


	Maximum = nanmax(isis,[],2);


	% compute dominant period from ISIs
	metrics = sourcedata.ISI2DominantPeriod(spikes, isis);
	
	DomPeriods{i} = metrics.DominantPeriod;
	ACF_values{i} = metrics.ACF_values;
	NormPeriodRange{i} = metrics.NormPeriodRange;

end


M.PD_IrregularBursts = NormPeriodRange{1} > .5 | isnan(NormPeriodRange{1});
M.LP_IrregularBursts = NormPeriodRange{2} > .5 | isnan(NormPeriodRange{2});



M.PD_T_InRange = DomPeriods{1} < 2 & DomPeriods{1} > .3;
M.LP_T_InRange = DomPeriods{2} < 2 & DomPeriods{2} > .3;

M.PD_T_LT_Max = DomPeriods{1}<nanmax(alldata.PD_PD,[],2);
M.LP_T_LT_Max = DomPeriods{2}<nanmax(alldata.LP_LP,[],2);
M.PD_T_LT_2Max = DomPeriods{1}<2*nanmax(alldata.PD_PD,[],2);
M.LP_T_LT_2Max =  DomPeriods{2}<2*nanmax(alldata.LP_LP,[],2);

M.PD_ACF_OK = ACF_values{1} > .8;
M.LP_ACF_OK = ACF_values{2} > .8;


M.PD_T = DomPeriods{1};
M.LP_T = DomPeriods{2};

% temp = nanmax(alldata.PD_PD,[],2);
% temp(isnan(temp)) = 20;
% M.PDMax = temp;

% temp = nanmax(alldata.LP_LP,[],2);
% temp(isnan(temp)) = 20;
% M.LPMax = temp;

% compute difference b/w biggest and 2nd biggest ISIs
temp = sort(alldata.PD_PD,2,'descend','MissingPlacement','last');
temp = temp(:,1:2);
D = mean(temp,2);
temp = temp(:,1)-temp(:,2);
temp = temp./D;
M.PD_ISIsVary = temp > .2;

temp = sort(alldata.LP_LP,2,'descend','MissingPlacement','last');
temp = temp(:,1:2);
D = mean(temp,2);
temp = temp(:,1)-temp(:,2);
temp = temp./D;
M.LP_ISIsVary = temp > .2;



M.SyncLP = 1./nanmin(alldata.LP_PD,[],2);
M.SyncPD = 1./nanmin(alldata.PD_LP,[],2);
M.SyncLP(M.SyncLP<(1/50e-3)) = 0;
M.SyncPD(M.SyncPD<(1/50e-3)) = 0;
M.SyncLP = 1*M.SyncLP./nanmax(M.SyncLP);
M.SyncPD = 1*M.SyncPD./nanmax(M.SyncPD);
M.SyncLP(isnan(M.SyncLP)) = 1;
M.SyncPD(isnan(M.SyncPD)) = 1;


% check if neurons are tonic
M.LPTonic = nanmax(alldata.LP,[],2) - nanmin(alldata.LP,[],2) > 19 & nanmax(alldata.LP_LP,[],2) < .5 & nanstd(alldata.LP_LP,[],2)./nanmean(alldata.LP_LP,2) < .2;
M.PDTonic = nanmax(alldata.PD,[],2) - nanmin(alldata.PD,[],2) > 19 & nanmax(alldata.PD_PD,[],2) < .5 & nanstd(alldata.PD_PD,[],2)./nanmean(alldata.PD_PD,2) < .2;

% M.PDphase = (nanmean(alldata.LP_PD,2)./M.PD_T);
% M.LPphase = (nanmean(alldata.PD_LP,2)./M.LP_T);
% M.PDphase(M.PD_T == 20) = -1;
% M.LPphase(M.LP_T == 20) = -1;
% M.PDphase(isnan(M.PDphase)) = -1;
% M.LPphase(isnan(M.LPphase)) = -1;

% % scale
% M.PDphase = M.PDphase*10;
% M.LPphase = M.LPphase*10;



% include info about firing rate
V2 = [20./(sum(~isnan(alldata.PD),2)+1) 20./(sum(~isnan(alldata.LP),2)+1)];


V = struct2array(M);
VectorisedPercentiles = [V V2];