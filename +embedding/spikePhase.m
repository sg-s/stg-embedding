function [PDphases, LPphases] = spikePhase(alldata,DelayPercentileVec)

N = length(alldata.mask);

% measure a "phase" for every spike defined by timing of the other neuron
PDphases = NaN(N,length(DelayPercentileVec));
LPphases = NaN(N,length(DelayPercentileVec));

disp('Computing pseudo phases...')

for i = 1:N

	corelib.textbar(i,N)

	spikes = alldata.PD(i,:);
	otherspikes = alldata.LP(i,:);
	phases = NaN(length(spikes),1)-1;

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

	PDphases(i,:) = prctile(phases,DelayPercentileVec);




	spikes = alldata.LP(i,:);
	otherspikes = alldata.PD(i,:);
	phases = NaN(length(spikes),1)-1;

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

	LPphases(i,:) = prctile(phases,DelayPercentileVec);


end
