% converts spiketimes into a vectorized representation
% using nominal burst starts and ends
% which are in turn estimated by their position
% relative to the other neuron

function [Metrics, NMetrics, VectorizedData] = vectorizeSpikes(alldata)


assert(length(alldata)==1,'Expected DataStore to be scalar')


N = length(alldata.mask);
neurons = {'PD','LP'};


% placeholders
% p.PD_burst_period_mean = NaN(N,1);
p.PD_burst_period_cv = NaN(N,1);
p.PD_burst_period_max = NaN(N,1);
p.PD_burst_period_min = NaN(N,1);

% p.LP_burst_period_mean = NaN(N,1);
p.LP_burst_period_cv = NaN(N,1);
p.LP_burst_period_max = NaN(N,1);
p.LP_burst_period_min = NaN(N,1);

% p.LP_phase_mean = NaN(N,1);
% p.LP_phase_cv = NaN(N,1);
% p.LP_phase_max = NaN(N,1);
% p.LP_phase_min = NaN(N,1);

% p.PD_phase_mean = NaN(N,1);
% p.PD_phase_cv = NaN(N,1);
% p.PD_phase_max = NaN(N,1);
% p.PD_phase_min = NaN(N,1);


% p.LP_dc_mean = NaN(N,1);
p.LP_dc_cv = NaN(N,1);
p.LP_dc_cv2 = NaN(N,1);
p.LP_dc_max = NaN(N,1);
p.LP_dc_max2 = NaN(N,1);
p.LP_dc_min = NaN(N,1);

% p.PD_dc_mean = NaN(N,1);
p.PD_dc_cv = NaN(N,1);
p.PD_dc_cv2 = NaN(N,1);
p.PD_dc_max = NaN(N,1);
p.PD_dc_max2 = NaN(N,1);
p.PD_dc_min = NaN(N,1);


% ratio of LP to PD periods
% p.PeriodError = NaN(N,1);



p.PD_isi_max = NaN(N,1);
p.LP_isi_max = NaN(N,1);
p.PD_isi_min = nanmin(alldata.PD_PD,[],2);
p.LP_isi_min = nanmin(alldata.LP_LP,[],2);

% 1/delays, capped
p.LP_PD = 1./nanmin(alldata.LP_PD,[],2);
p.PD_LP = 1./nanmin(alldata.LP_PD,[],2);
p.LP_PD(p.LP_PD>20) = 20;
p.PD_LP(p.PD_LP>20) = 20;


% ratio of max of 2nd to max of 1st order ISI
p.PD_second_order = NaN(N,1);
p.LP_second_order = NaN(N,1);


% max of ratios of ISIs (1st./2...5th)
p.PD_isi_ratios = NaN(N,1);
p.LP_isi_ratios = NaN(N,1);



% also firing rates
p.PDf = sum(~isnan(alldata.PD),2);
p.LPf = sum(~isnan(alldata.LP),2);



% flag for wheter we pick strict or non-strict burst metrics
p.PD_strict = zeros(N,1);
p.LP_strict = zeros(N,1);


% compute spike phases, which are always defined (except when neurons are silent)
[PD_spike_phases, LP_spike_phases] = embedding.spikePhase(alldata,[0 5 95 100]);
PD_spike_phases(isnan(PD_spike_phases)) = -1;
LP_spike_phases(isnan(LP_spike_phases)) = -1;
p.PD_spike_phases0 = PD_spike_phases(:,1);
p.PD_spike_phases5 = PD_spike_phases(:,2);
p.PD_spike_phases95 = PD_spike_phases(:,3);
p.PD_spike_phases100 = PD_spike_phases(:,4);

p.LP_spike_phases0 = LP_spike_phases(:,1);
p.LP_spike_phases5 = LP_spike_phases(:,2);
p.LP_spike_phases95 = LP_spike_phases(:,3);
p.LP_spike_phases100 = LP_spike_phases(:,4);



% compute burstiness from ISIs
p.PD_burstiness = NaN(N,1);
p.LP_burstiness = NaN(N,1);
for i = 1:N
	PD = sort(alldata.PD_PD(i,:));
	[isi_gap,pos] = max(diff(PD));
	p.PD_burstiness(i) = isi_gap/PD(pos);


	LP = sort(alldata.LP_LP(i,:));
	[isi_gap,pos] = max(diff(LP));
	p.LP_burstiness(i) = isi_gap/LP(pos);
end
% cap
p.LP_burstiness(p.LP_burstiness>10) = 10;
p.PD_burstiness(p.PD_burstiness>10) = 10;
p.PD_burstiness(isnan(p.PD_burstiness)) = -1;
p.LP_burstiness(isnan(p.LP_burstiness)) = -1;

% find longest period of silence
p.longest_silence = nanmax(diff(sort([alldata.PD alldata.LP],2),[],2),[],2);
p.longest_silence(isnan(p.longest_silence)) = 20;


disp('Computing burst starts and stops...')

for i = 1:N

	corelib.textbar(i,N)

	PD = alldata.PD(i,:);
	LP = alldata.LP(i,:);

	offset = nanmin([PD(:); LP(:)]);

	PD = PD - offset;
	LP = LP - offset;

	[PD_burst_starts, PD_burst_stops,PD_burst_starts_strict, PD_burst_stops_strict] = embedding.findNominalBurstStartsStops(PD,LP);
	[LP_burst_starts, LP_burst_stops,LP_burst_starts_strict, LP_burst_stops_strict] = embedding.findNominalBurstStartsStops(LP,PD);


	% figure out if we want to use strict or non-strict metrics
	if nanstd(diff(PD_burst_starts)) > nanstd(diff(PD_burst_starts_strict))
		p.PD_strict(i) = 1;
		PD_burst_starts = PD_burst_starts_strict;
		PD_burst_stops = PD_burst_stops_strict;
	end

	if nanstd(diff(LP_burst_starts)) > nanstd(diff(LP_burst_starts_strict))
		p.LP_strict(i) = 1;
		LP_burst_starts = LP_burst_starts_strict;
		LP_burst_stops = LP_burst_stops_strict;
	end

	PD_burst_periods = diff(PD_burst_starts);
	LP_burst_periods = diff(LP_burst_starts);



	% error('NO')
	% figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

	% neurolib.raster(PD,'deltat',1,'center',false,'yoffset',0)
	% neurolib.raster(LP,'deltat',1,'center',false,'yoffset',1)
	% plot(LP_burst_starts_strict,LP_burst_starts_strict*0+1.96,'go')
	% plot(LP_burst_stops_strict,LP_burst_stops_strict*0+1.95,'rd')

	% plot(PD_burst_starts_strict,PD_burst_starts_strict*0+.96,'go')
	% plot(PD_burst_stops_strict,PD_burst_stops_strict*0+.95,'rd')



	LP_phases = PD_burst_starts*NaN;
	PD_phases = LP_burst_starts*NaN;

	LP_dc = LP_burst_starts*NaN;
	PD_dc = PD_burst_starts*NaN;


	% measure duty cycles
	for j = 1:length(PD_dc)-1
		next_PD_stop = PD_burst_stops(find(PD_burst_stops>=PD_burst_starts(j),1,'first'));
		if isempty(next_PD_stop)
			continue
		end
		PD_dc(j) = next_PD_stop - PD_burst_starts(j);
	end

	for j = 1:length(LP_dc)-1
		next_LP_stop = LP_burst_stops(find(LP_burst_stops>=LP_burst_starts(j),1,'first'));
		if isempty(next_LP_stop)
			continue
		end
		LP_dc(j) = next_LP_stop - LP_burst_starts(j);
	end



	% measure LP delay in PD time
	for j = 1:length(LP_phases)-1
		next_LP_start = LP_burst_starts(find(LP_burst_starts>PD_burst_starts(j),1,'first'));
		if isempty(next_LP_start)
			continue
		end
		LP_phases(j) = next_LP_start - PD_burst_starts(j);
	end

	% measure PD delay in LP time
	for j = 1:length(PD_phases)-1
		next_PD_start = PD_burst_starts(find(PD_burst_starts>LP_burst_starts(j),1,'first'));
		if isempty(next_PD_start)
			continue
		end
		PD_phases(j) = next_PD_start - LP_burst_starts(j);
	end



	LP_phases(1:end-1) = LP_phases(1:end-1)./PD_burst_periods;
	PD_phases(1:end-1) = PD_phases(1:end-1)./LP_burst_periods;

	LP_dc(1:end-1) = LP_dc(1:end-1)./LP_burst_periods;
	PD_dc(1:end-1) = PD_dc(1:end-1)./PD_burst_periods;


	% sort PD burst periods
	PD_burst_periods = sort(PD_burst_periods,'descend','MissingPlacement','last');
	LP_burst_periods = sort(LP_burst_periods,'descend','MissingPlacement','last');
	PD_dc = sort(PD_dc,'descend','MissingPlacement','last');
	LP_dc = sort(LP_dc,'descend','MissingPlacement','last');

	% p.PD_burst_period_mean(i) = nanmean(PD_burst_periods);
	p.PD_burst_period_max(i) = PD_burst_periods(1);
	p.PD_burst_period_min(i) = nanmin(PD_burst_periods);

	% p.LP_burst_period_mean(i) = nanmean(LP_burst_periods);
	p.LP_burst_period_max(i) = LP_burst_periods(1);
	p.LP_burst_period_min(i) = nanmin(LP_burst_periods);


	% p.PD_dc_mean(i) = nanmean(PD_dc);
	p.PD_dc_max(i) = PD_dc(1);
	p.PD_dc_max2(i) = PD_dc(2);
	p.PD_dc_min(i) = nanmin(PD_dc);
	
	% p.LP_dc_mean(i) = nanmean(LP_dc);
	p.LP_dc_max(i) = LP_dc(1);
	p.LP_dc_max2(i) = LP_dc(2);
	p.LP_dc_min(i) = nanmin(LP_dc);

end

% phases beyond [0 1] are meaningless
% p.PD_phase_mean(p.PD_phase_mean>1) = NaN;
% p.PD_phase_max(p.PD_phase_max>1) = NaN;
% p.PD_phase_min(p.PD_phase_min>1) = NaN;
% p.LP_phase_mean(p.LP_phase_mean>1) = NaN;
% p.LP_phase_max(p.LP_phase_max>1) = NaN;
% p.LP_phase_min(p.LP_phase_min>1) = NaN;

% duty cycles beyond 1 are meaningless
% p.PD_dc_mean(p.PD_dc_mean>1) = NaN;
p.PD_dc_max(p.PD_dc_max>1) = NaN;
p.PD_dc_max2(p.PD_dc_max2>1) = NaN;
p.PD_dc_min(p.PD_dc_min>1) = NaN;
% p.LP_dc_mean(p.LP_dc_mean>1) = NaN;
p.LP_dc_max(p.LP_dc_max>1) = NaN;
p.LP_dc_max2(p.LP_dc_max2>1) = NaN;
p.LP_dc_min(p.LP_dc_min>1) = NaN;




% compute the ranges/variability in one fell swoop
p.LP_burst_period_cv = exp(p.LP_burst_period_max./p.LP_burst_period_min - 1);
p.PD_burst_period_cv = exp(p.PD_burst_period_max./p.PD_burst_period_min - 1);
p.LP_dc_cv = exp(p.LP_dc_max./p.LP_dc_min - 1);
p.PD_dc_cv = exp(p.PD_dc_max./p.PD_dc_min - 1);
p.LP_dc_cv2 = exp(p.LP_dc_max./p.LP_dc_max2 - 1);
p.PD_dc_cv2 = exp(p.PD_dc_max./p.PD_dc_max2 - 1);



% cap them
p.LP_burst_period_cv(p.LP_burst_period_cv>10) = 10;
p.PD_burst_period_cv(p.PD_burst_period_cv>10) = 10;
p.LP_dc_cv(p.LP_dc_cv>10) = 10;
p.PD_dc_cv(p.PD_dc_cv>10) = 10;
p.LP_dc_cv2(p.LP_dc_cv2>10) = 10;
p.PD_dc_cv2(p.PD_dc_cv2>10) = 10;


% either can be higher, so we can't do simple division as before
p.PeriodError = abs(p.PD_burst_period_max - p.LP_burst_period_max)./(p.PD_burst_period_max + p.LP_burst_period_max);
p.PeriodError = exp(p.PeriodError);










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

	end
end

% cap the ratios and exaggerate them
p.PD_isi_ratios(p.PD_isi_ratios>3)=  3;
p.LP_isi_ratios(p.LP_isi_ratios>3)=  3;

% exxagerate isi ratios
p.PD_isi_ratios = exp(p.PD_isi_ratios-1);
p.LP_isi_ratios = exp(p.LP_isi_ratios-1);



Metrics = p;
NMetrics = Metrics;


% normalize 
fn = fieldnames(NMetrics);
for i = 1:length(fn)
	M = nanmedian(NMetrics.(fn{i}));
	S = nanstd(NMetrics.(fn{i}));
	NMetrics.(fn{i}) = NMetrics.(fn{i}) - M;
	NMetrics.(fn{i}) = NMetrics.(fn{i})/S;
end


% handle missing data and exceptions 


% burst periods
% NMetrics.PD_burst_period_mean(isnan(NMetrics.PD_burst_period_mean)) = -10;
% NMetrics.LP_burst_period_mean(isnan(NMetrics.LP_burst_period_mean)) = -10;
NMetrics.PD_burst_period_min(isnan(NMetrics.PD_burst_period_min)) = -1;
NMetrics.LP_burst_period_min(isnan(NMetrics.LP_burst_period_min)) = -1;
NMetrics.PD_burst_period_max(isnan(NMetrics.PD_burst_period_max)) = -1;
NMetrics.LP_burst_period_max(isnan(NMetrics.LP_burst_period_max)) = -1;



% phases
% NMetrics.PD_phase_max(isnan(NMetrics.PD_phase_max)) = -1;
% NMetrics.LP_phase_max(isnan(NMetrics.LP_phase_max)) = -1;
% NMetrics.PD_phase_min(isnan(NMetrics.PD_phase_min)) = 2;
% NMetrics.LP_phase_min(isnan(NMetrics.LP_phase_min)) = 2;
% NMetrics.PD_phase_mean(isnan(NMetrics.PD_phase_mean)) = -1;
% NMetrics.LP_phase_mean(isnan(NMetrics.LP_phase_mean)) = -1;


% duty cycles
NMetrics.PD_dc_max(isnan(NMetrics.PD_dc_max)) = -1;
NMetrics.LP_dc_max(isnan(NMetrics.LP_dc_max)) = -1;
NMetrics.PD_dc_min(isnan(NMetrics.PD_dc_min)) = 2;
NMetrics.LP_dc_min(isnan(NMetrics.LP_dc_min)) = 2;
% NMetrics.PD_dc_mean(isnan(NMetrics.PD_dc_mean)) = -1;
% NMetrics.LP_dc_mean(isnan(NMetrics.LP_dc_mean)) = -1;




% fill in NaNs in some fields with the maximum value,
% because higher values = "bad" in these fields
fields = fieldnames(NMetrics);
for i = 1:length(fields)
	NMetrics.(fields{i}) = embedding.nan2max(NMetrics.(fields{i}));
end




VectorizedData = struct2array(NMetrics);