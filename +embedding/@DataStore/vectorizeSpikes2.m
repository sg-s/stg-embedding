% converts spiketimes into a vectorized representation
% using nominal burst starts and ends
% which are in turn estimated by their position
% relative to the other neuron

function [Metrics, NMetrics, VectorizedData] = vectorizeSpikes2(alldata)


assert(length(alldata)==1,'Expected DataStore to be scalar')


N = length(alldata.mask);
neurons = {'PD','LP'};



p.PD_isi_max = NaN(N,1);
p.LP_isi_max = NaN(N,1);
p.PD_isi_min = nanmin(alldata.PD_PD,[],2);
p.LP_isi_min = nanmin(alldata.LP_LP,[],2);


% ratio of max of 2nd to max of 1st order ISI
p.PD_second_order = NaN(N,1);
p.LP_second_order = NaN(N,1);


% max of ratios of ISIs (1st./2...5th)
p.PD_isi_ratios = NaN(N,1);
p.LP_isi_ratios = NaN(N,1);


p.PD_burstiness = NaN(N,1);
p.LP_burstiness = NaN(N,1);



p.PD_closer_to_LP = zeros(N,1);
p.LP_closer_to_PD = zeros(N,1);



p.PD_within_LP = zeros(N,1);
p.LP_within_PD = zeros(N,1);



% find longest period of silence
% taking into account gaps at the end, which will not appear
% by simply taking ISIs
p.longest_silence = NaN(N,1);



% firing rates
p.PDf = log(sum(~isnan(alldata.PD),2));
p.LPf = log(sum(~isnan(alldata.LP),2));
p.PDf(isinf(p.PDf)) = -5;
p.LPf(isinf(p.LPf)) = -5;

p.PD_skipped = zeros(N,1);
p.LP_skipped = zeros(N,1);





[PD_spike_phases, LP_spike_phases] = embedding.spikePhase(alldata,[0 100]);
PD_spike_phases(isnan(PD_spike_phases)) = -1;
LP_spike_phases(isnan(LP_spike_phases)) = -1;
p.PD_spike_phases0 = PD_spike_phases(:,1);
p.PD_spike_phases100 = PD_spike_phases(:,2);

p.LP_spike_phases0 = LP_spike_phases(:,1);
p.LP_spike_phases100 = LP_spike_phases(:,2);







% longest silence
disp('Computing longest silence...')
for i = 1:N
	spikes = [alldata.PD(i,:) alldata.LP(i,:)];
	spikes = spikes - nanmin(spikes);
	spikes(end) = 20;
	spikes = sort(spikes);
	p.longest_silence(i) = nanmax(diff(spikes));
end
p.longest_silence(isnan(p.longest_silence)) = 20;



% compute burstiness from ISIs
for i = 1:N
	isis = sort(alldata.PD_PD(i,:));
	disis = diff(isis);
	disis = disis./isis(1:end-1);
	p.PD_burstiness(i) = max(disis);


	isis = sort(alldata.LP_LP(i,:));
	disis = diff(isis);
	disis = disis./isis(1:end-1);
	p.LP_burstiness(i) = max(disis);
end
% cap
p.LP_burstiness(p.LP_burstiness>5) = 5;
p.PD_burstiness(p.PD_burstiness>5) = 5;

p.LP_burstiness(p.LP_burstiness<1) = NaN;
p.PD_burstiness(p.PD_burstiness<1) = NaN;







% compute 2nd order ISIs
disp('Computing 2nd order ISIs...')
for i = 1:length(neurons)

	for j = 1:N
		corelib.textbar(j,N)
		spikes = alldata.(neurons{i})(j,:);
		spikes = spikes - nanmin(spikes);

		% check if there is a large empty section
		maxisi = max(diff(spikes));
		if (20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes)))) > 2*maxisi
			spikes(find(isnan(spikes),1,'first')) = max(spikes)+(20-max(spikes(~isnan(spikes)))-min(spikes(~isnan(spikes))));
		end


		% compute 1st order ISIs
		spikes2 = circshift(spikes,1);
		isis = spikes-spikes2;
		isis(isis<0.003) = NaN;
		p.([neurons{i} '_isi_max'])(j,:) = nanmax(isis);



		% compute 2nd order ISIs
		spikes2 = circshift(spikes,2);
		isis2 = spikes-spikes2;
		isis2(isis2<0.003) = NaN;

		p.([neurons{i} '_second_order'])(j) = nanmax(isis2)/nanmax(isis);

		% compute ISI ratios
		isis = sort(isis,'descend','MissingPlacement','last');
		p.([neurons{i} '_isi_ratios'])(j) = nanmax(isis(1)./isis(2:5));
		%p.([neurons{i} '_isi_ratios'])(j) = isis(1)./isis(2);

	end
end

% cap the ratios and exaggerate them
p.PD_isi_ratios(p.PD_isi_ratios>3)=  3;
p.LP_isi_ratios(p.LP_isi_ratios>3)=  3;

% exxagerate isi ratios
p.PD_isi_ratios = exp(p.PD_isi_ratios-1);
p.LP_isi_ratios = exp(p.LP_isi_ratios-1);




% check if spikes are closer to spikes on other neurons than same neuron
PD = alldata.PD;
LP = alldata.LP;
PD_closer_to_LP = zeros(N,1);
LP_closer_to_PD = zeros(N,1);

parfor i = 1:N

	this_PD = PD(i,:);
	this_LP = LP(i,:);

	for j = 2:length(this_PD)-1

		if isnan(this_PD(j+1))
			break
		end

		closest_PD_spike = nanmin([this_PD(j)-this_PD(j-1) this_PD(j+1)-this_PD(j)]);
		closest_LP_spike = nanmin(abs(this_LP - this_PD(j)));
		if closest_LP_spike < closest_PD_spike
			PD_closer_to_LP(i) = 1;
			break
		end

		
	end

	for j = 2:length(this_LP)-1

		if isnan(this_LP(j+1))
			break
		end

		closest_LP_spike = nanmin([this_LP(j)-this_LP(j-1) this_LP(j+1)-this_LP(j)]);
		closest_PD_spike = nanmin(abs(this_PD - this_LP(j)));
		if closest_PD_spike < closest_LP_spike
			LP_closer_to_PD(i) = 1;
			break
		end
		
	end
end

p.PD_closer_to_LP = PD_closer_to_LP;
p.LP_closer_to_PD = LP_closer_to_PD;


% closeness shouldn't matter for non-bursting neurons
p.PD_closer_to_LP(isnan(p.LP_burstiness)) = -1;
p.PD_closer_to_LP(isnan(p.PD_burstiness)) = -1;
p.LP_closer_to_PD(isnan(p.LP_burstiness)) = -1;
p.LP_closer_to_PD(isnan(p.PD_burstiness)) = -1;







% check if PD and LP are contained within the other neuron

PD = alldata.PD;
LP = alldata.LP;
PD_within_LP = zeros(N,1);
LP_within_PD = zeros(N,1);

parfor i = 1:N

	PD_within_LP(i) = embedding.isAwithinB(PD(i,:),LP(i,:));
	LP_within_PD(i) = embedding.isAwithinB(LP(i,:),PD(i,:));

end

p.PD_within_LP = PD_within_LP;
p.LP_within_PD = LP_within_PD;


% withinness shouldn't matter for single-spiker bursters
p.PD_within_LP(p.LP_second_order>1.5) = -1;
p.LP_within_PD(p.PD_second_order>1.5) = -1;


% check for skipped bursts
% we're looking for the ratio of # of spikes in the longest
% to second longest ISIs
PD_skipped = zeros(N,1);
LP_skipped = zeros(N,1);

tic
parfor i = 1:N
	PD_skipped(i) = embedding.skippedBurstDetector(PD(i,:),LP(i,:));
	LP_skipped(i) = embedding.skippedBurstDetector(LP(i,:),PD(i,:));
end
toc

p.PD_skipped = PD_skipped;
p.LP_skipped = LP_skipped;









Metrics = p;
NMetrics = Metrics;



% missing values
NMetrics.PD_burstiness = embedding.replaceNaNWith(NMetrics.PD_burstiness,-1);
NMetrics.LP_burstiness = embedding.replaceNaNWith(NMetrics.LP_burstiness,-1);

NMetrics.LP_isi_min = embedding.replaceNaNWith(NMetrics.LP_isi_min,20);
NMetrics.PD_isi_min = embedding.replaceNaNWith(NMetrics.PD_isi_min,20);

NMetrics.LP_isi_max = embedding.replaceNaNWith(NMetrics.LP_isi_max,@nanmax);
NMetrics.PD_isi_max = embedding.replaceNaNWith(NMetrics.PD_isi_max,@nanmax);


% fill in NaNs in some fields with the maximum value,
% because higher values = "bad" in these fields
fields = fieldnames(NMetrics);
for i = 1:length(fields)
	NMetrics.(fields{i}) = embedding.replaceNaNWith(NMetrics.(fields{i}),@nanmax);
end




% normalize 
fn = fieldnames(NMetrics);
for i = 1:length(fn)
	M = nanmean(NMetrics.(fn{i}));
	S = nanstd(NMetrics.(fn{i}));
	NMetrics.(fn{i}) = NMetrics.(fn{i}) - M;
	NMetrics.(fn{i}) = NMetrics.(fn{i})/S;
end







VectorizedData = struct2array(NMetrics);