% takes spike times, aligns to first PD spikes,
% convolves with a Gaussian and that's your vector
function V = spikeAlignedVectors(alldata)


BinSize = .01; % 10 ms

neurons = {'PD','LP'};

DataSize = length(alldata.mask);

M = struct;


% PD

PDf = zeros(DataSize,2e3);
LPf = zeros(DataSize,2e3);

for j = 1:DataSize

	PD = alldata.PD(j,:);
	PD = round(PD/BinSize);
	LP = alldata.LP(j,:);
	LP = round(LP/BinSize);

	offset = min([PD LP]);

	if isnan(offset)
		continue
	end


	PD = PD - offset;
	LP = LP - offset;


	if any(~isnan(PD))
		PDf(j,PD(PD>0 & ~isnan(PD))) = 1;
	end
	if any(~isnan(LP))
		LPf(j,LP(LP>0 & ~isnan(LP))) = 1;
	end

	
end

% convolve with Gaussian
G = normpdf(-3:.3:3);
for j = 1:DataSize
	PDf(j,:) = filtfilt(G,1,PDf(j,:));
	LPf(j,:) = filtfilt(G,1,LPf(j,:));
end


% downsample
PDf  = PDf(:,1:10:end);
LPf  = LPf(:,1:10:end);

V = [PDf LPf PDf-LPf];

