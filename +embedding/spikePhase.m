% computes the pseudo-phase of every spike in A as
% defined by the time in B
% this can always be defined, no matter what the activity
% of A and B are. 

function [PDphasesPrcTile, LPphasesPrcTile, PDphases, LPphases] = spikePhase(alldata,DelayPercentileVec)

arguments
	alldata (1,1) embedding.DataStore
	DelayPercentileVec (:,1) = [0 5 95 100]
end

N = length(alldata.mask);

% measure a "phase" for every spike defined by timing of the other neuron
PDphasesPrcTile = NaN(N,length(DelayPercentileVec));
LPphasesPrcTile = NaN(N,length(DelayPercentileVec));


PDphases = NaN(N,1e3);
LPphases = NaN(N,1e3);

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

		% override phases if this spike occurs between two closely occurring spikes on the other neuron
		if next_other_spike-prev_other_spike < .1
			phases(j) = 0;
		end
	end

	PDphases(i,:) = phases;

	PDphasesPrcTile(i,:) = prctile(phases,DelayPercentileVec);





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

		% override phases if this spike occurs between two closely occurring spikes on the other neuron
		if next_other_spike-prev_other_spike < .1
			phases(j) = 0;
		end
	end

	LPphases(i,:) = phases;
	LPphasesPrcTile(i,:) = prctile(phases,DelayPercentileVec);



end
