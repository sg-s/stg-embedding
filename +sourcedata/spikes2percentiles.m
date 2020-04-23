% this function converts raw spike times to nth order ISIs
% then computes percentiles of that, and gloms everything 
% together to create a long vector
% delays between neurons are handled separately, and simple 1st order
% delays are used. this is not actually computed, and is assumed to 
% already exist in alldata 

function p = spikes2percentiles(alldata, varargin)

options.ISIorders = 1:10;
options.PercentileVec = linspace(0,100,11);
options.DelayPercentileVec = linspace(0,100,11);
options.neurons = {'PD','LP'};
options = corelib.parseNameValueArguments(options,varargin{:});

structlib.packUnpack(options);


DataFrameSize = length(ISIorders)*length(PercentileVec);

% make placeholders 
for i = 1:length(neurons)
	N = size(alldata.(neurons{i}),1);
	p.([neurons{i} '_' neurons{i}]) = NaN(N,DataFrameSize);

end



% compute percentiles for nth order isis
for i = 1:length(neurons)
	N = size(alldata.(neurons{i}),1);
	for j = 1:N
		corelib.textbar(j,N)
		spikes = alldata.(neurons{i})(j,:);

		% check if there is a large empty section
		maxisi = max(diff(spikes));
		if (20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes)))) > maxisi
			spikes(find(isnan(spikes),1,'first')) = max(spikes)+(20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes))));
		end

		a = 1;
		z = a + length(PercentileVec) - 1;
		for k = 1:length(ISIorders)
			spikes2 = circshift(spikes,ISIorders(k));

			isis = spikes-spikes2;
			isis(isis<0.01) = NaN;

			p.([neurons{i} '_' neurons{i}])(j,a:z) = prctile(isis,PercentileVec);

			a = z + 1;
			z = a + length(PercentileVec) - 1;

		end
	end
end

% compute cross ISI percentiles
for i = 1:length(neurons)
	for j = 1:length(neurons)
		if i == j
			continue
		end

		for k = N:-1:1
			p.([neurons{i} '_' neurons{j}])(k,:) = prctile(alldata.([neurons{i} '_' neurons{j}])(k,:),DelayPercentileVec);
		end

	end

end


