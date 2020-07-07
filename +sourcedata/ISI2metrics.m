% test function that wraps spikes2percentiles and attempts
% to return metrics that have meaning
% this doesn't work well
% abandoned
function M = ISI2metrics(alldata)

[p, VectorisedPercentiles] = sourcedata.spikes2percentiles(alldata,'ISIorders',[1:20]);


DataSize = length(alldata.mask);


fn = {'PD_PD','LP_LP'};
V = struct; % variability in "period"
N = struct; % "# of spikes"
T = struct; % "period"
for k = 1:length(fn)
	p.(fn{k}) = reshape(p.(fn{k}),DataSize,11,20);
	m = squeeze(mean(p.(fn{k}),2));
	s = squeeze(std(p.(fn{k}),[],2));

	% it's impossible to have zero variance, so let's ignore that
	s(s==0) = Inf;

	[V.(fn{k}),N.(fn{k})] = min(s,[],2);

	T.(fn{k}) = NaN(DataSize,1);

	for i = 1:DataSize
		if isnan(N.(fn{k})(i))
			continue
		end
		T.(fn{k})(i) = m(i,N.(fn{k})(i));
	end

	keyboard

	% suppress NaNs
	N.(fn{k})(isnan(T.(fn{k}))) = -10;

end

% make a giant matrix of the features we select
     % PD ISIs      % period # N    % var     % LP isis    
M = [T.PD_PD N.PD_PD V.PD_PD T.LP_LP N.LP_LP V.LP_LP   p.LP_PD p.PD_LP];
M(isnan(M)) = -10;

M(isinf(M)) = -1;