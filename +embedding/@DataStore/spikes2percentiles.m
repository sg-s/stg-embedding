% this function converts raw spike times to nth order ISIs
% then computes percentiles of that, and gloms everything 
% together to create a long vector
% delays between neurons are handled separately, and simple 1st order
% delays are used. this is not actually computed, and is assumed to 
% already exist in alldata 

function [p, VectorizedData] = spikes2percentiles(alldata, varargin)


assert(isscalar(alldata),'Expected a scalar argument')

options.ISIorders = 1:2;
options.PercentileVec = [0 5 95 100];
options.DelayPercentileVec = [0 5 95 100];
options.neurons = {'PD','LP'};
options = corelib.parseNameValueArguments(options,varargin{:});

structlib.packUnpack(options);


DataFrameSize = length(PercentileVec);

N = length(alldata.mask);

% make placeholders 
for i = 1:length(neurons)
	p.([neurons{i} '_' neurons{i}]) = NaN(N,DataFrameSize);
	p.([neurons{i} '_' neurons{i} '_2']) = NaN(N,1);
	p.([neurons{i} '_' neurons{i} '_ratio']) = NaN(N,2);
end



% % compute percentiles for nth order isis
% for i = 1:length(neurons)
% 	N = size(alldata.(neurons{i}),1);
% 	for j = 1:N
% 		corelib.textbar(j,N)
% 		spikes = alldata.(neurons{i})(j,:);
% 		spikes = spikes - nanmin(spikes);

% 		% check if there is a large empty section
% 		maxisi = max(diff(spikes));
% 		if (20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes)))) > maxisi
% 			spikes(find(isnan(spikes),1,'first')) = max(spikes)+(20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes))));
% 		end

% 		a = 1;
% 		z = a + length(PercentileVec) - 1;
% 		for k = 1:length(ISIorders)
% 			spikes2 = circshift(spikes,ISIorders(k));

% 			isis = spikes-spikes2;
% 			isis(isis<0.001) = NaN;

% 			p.([neurons{i} '_' neurons{i}])(j,a:z) = prctile(isis,PercentileVec);;

% 			% if a > 1
% 			% 	% scale by 1st order ISIs
% 			% 	p.([neurons{i} '_' neurons{i}])(j,a:z) = p.([neurons{i} '_' neurons{i}])(j,a:z)./(p.([neurons{i} '_' neurons{i}])(j,1:length(PercentileVec)));
% 			% end


% 			a = z + 1;
% 			z = a + length(PercentileVec) - 1;

% 		end
% 	end
% end



% compute 2nd order ISIs
for i = 1:length(neurons)

	for j = 1:N
		corelib.textbar(j,N)
		spikes = alldata.(neurons{i})(j,:);
		spikes = spikes - nanmin(spikes);

		% check if there is a large empty section
		maxisi = max(diff(spikes));
		if (20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes)))) > maxisi
			spikes(find(isnan(spikes),1,'first')) = max(spikes)+(20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes))));
		end


		% compute 1st order ISIs
		spikes2 = circshift(spikes,1);
		isis = spikes-spikes2;
		isis(isis<0.003) = NaN;
		p.([neurons{i} '_' neurons{i}])(j,:) = prctile(isis,PercentileVec);



		% compute 2nd order ISIs
		spikes2 = circshift(spikes,2);
		isis2 = spikes-spikes2;
		isis2(isis2<0.003) = NaN;

		p.([neurons{i} '_' neurons{i} '_2'])(j) = nanmax(isis2)/nanmax(isis);

	
		isis = sort(isis,'descend','MissingPlacement','last');
		p.([neurons{i} '_' neurons{i} '_ratio'])(j,:) = isis(1)./isis(2:3); 

	end


end

% truncate ratios
p.PD_PD_ratio(p.PD_PD_ratio>3) = 3;
p.LP_LP_ratio(p.LP_LP_ratio>3) = 3;

% % compute cross ISI percentiles
% for i = 1:length(neurons)
% 	for j = 1:length(neurons)
% 		if i == j
% 			continue
% 		end

% 		for k = N:-1:1
% 			p.([neurons{i} '_' neurons{j}])(k,:) = prctile(alldata.([neurons{i} '_' neurons{j}])(k,:),DelayPercentileVec);
% 		end

% 	end

% end



% measure distance to closest spike on same neuron vs. to other neuron

% p.ClosestPD = NaN(N,length(PercentileVec));
% p.ClosestLP = NaN(N,length(PercentileVec));

% for i = N:-1:1

% 	spikes = alldata.PD(i,:);
% 	otherspikes = alldata.LP(i,:);
% 	isis = diff(spikes);
% 	isis2 = circshift(isis,1);

% 	closest_dist = nanmin([isis;isis2]);
% 	closest_dist_to_other_spike = pdist2(otherspikes(:),spikes(:),'Euclidean','Smallest',1);

% 	norm_closest = (closest_dist./closest_dist_to_other_spike(1:end-1));
% 	norm_closest(norm_closest>1) = 1;

% 	p.ClosestPD(i,:) = prctile(norm_closest,PercentileVec);



% 	spikes = alldata.LP(i,:);
% 	otherspikes = alldata.PD(i,:);
% 	isis = diff(spikes);
% 	isis2 = circshift(isis,1);

% 	closest_dist = nanmin([isis;isis2]);
% 	closest_dist_to_other_spike = pdist2(otherspikes(:),spikes(:),'Euclidean','Smallest',1);

% 	norm_closest = (closest_dist./closest_dist_to_other_spike(1:end-1));
% 	norm_closest(norm_closest>1) = 1;

% 	p.ClosestLP(i,:) = prctile(norm_closest,PercentileVec);

% end



% measure a "phase" for every spike defined by timing of the other neuron
p.PDphases = NaN(N,length(DelayPercentileVec));
p.LPphases = NaN(N,length(DelayPercentileVec));

disp('Computing pseudo phases...')

for i = 1:N

	corelib.textbar(i,N)

	spikes = alldata.PD(i,:);
	otherspikes = alldata.LP(i,:);
	phases = NaN*spikes;

	for j = 1:length(spikes)

		if isnan(spikes(j))
			break
		end
		prev_other_spike = otherspikes(find(otherspikes<spikes(j),1,'last'));
		
		if isempty(prev_other_spike)
			continue
		end
		next_other_spike = otherspikes(find(otherspikes>spikes(j),1,'first'));
		if isempty(next_other_spike)
			continue
		end

		phases(j) = (spikes(j)-prev_other_spike)/(next_other_spike-prev_other_spike);
	end

	p.PDphases(i,:) = prctile(phases,DelayPercentileVec);




	spikes = alldata.LP(i,:);
	otherspikes = alldata.PD(i,:);
	phases = NaN*spikes;

	for j = 1:length(spikes)

		if isnan(spikes(j))
			break
		end
		prev_other_spike = otherspikes(find(otherspikes<spikes(j),1,'last'));
		
		if isempty(prev_other_spike)
			continue
		end
		next_other_spike = otherspikes(find(otherspikes>spikes(j),1,'first'));
		if isempty(next_other_spike)
			continue
		end

		phases(j) = (spikes(j)-prev_other_spike)/(next_other_spike-prev_other_spike);
	end

	p.LPphases(i,:) = prctile(phases,DelayPercentileVec);


end




% compute # of spikes in other neuron as for every ISI in this neuron
% p.PDspikesInLPISIs = zeros(N,length(PercentileVec));
% p.LPspikesInPDISIs = zeros(N,length(PercentileVec));


% for k = N:-1:1

% 	nspikes = NaN(1e3,1);
% 	spikes = alldata.LP(k,:);
% 	otherspikes = alldata.PD(k,:);

% 	for i = 1:length(spikes)-1
% 		if isnan(spikes(i+1))
% 			break
% 		end
% 		nspikes(i) = sum(otherspikes>spikes(i) & otherspikes<spikes(i+1));
% 	end
% 	p.PDspikesInLPISIs(k,:) = prctile(nspikes,PercentileVec);



% 	nspikes = NaN(1e3,1);
% 	spikes = alldata.PD(k,:);
% 	otherspikes = alldata.LP(k,:);

% 	for i = 1:length(spikes)-1
% 		if isnan(spikes(i+1))
% 			break
% 		end
% 		nspikes(i) = sum(otherspikes>spikes(i) & otherspikes<spikes(i+1));
% 	end
% 	p.LPspikesInPDISIs(k,:) = prctile(nspikes,PercentileVec);

% end



% flip the delays to pick out synchronous spikes
% p.LP_PD2 = 1./p.LP_PD;
% p.PD_LP2 = 1./p.PD_LP;

Exxagerate = 2;
VectorizedData = ([p.PD_PD, p.LP_LP, p.PDphases, p.LPphases, p.PD_PD_ratio, p.LP_LP_ratio, p.PD_PD_2, p.LP_LP_2]);

VectorizedData(isinf(VectorizedData)) = NaN;

% normalise all columns
for i = 1:size(VectorizedData,2)
	M = nanmedian(VectorizedData(:,i));
	S = nanstd(VectorizedData(:,i));
	VectorizedData(:,i) = VectorizedData(:,i) - M;
	VectorizedData(:,i) = VectorizedData(:,i)/S;
end



VectorizedData(isnan(VectorizedData)) = -10;