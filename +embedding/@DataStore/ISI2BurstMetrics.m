function p = ISI2BurstMetrics(alldata)

assert(length(alldata)==1,'Expected a scalar DataStore')

N = length(alldata.mask);


PD_burst_period = NaN(N,1);
PD_duty_cycle = NaN(N,1);
LP_burst_period = NaN(N,1);
LP_duty_cycle = NaN(N,1);
LP_delay_on = NaN(N,1);
LP_delay_off = NaN(N,1);
LP_phase_off = NaN(N,1);
LP_phase_on = NaN(N,1);
PD_nspikes = NaN(N,1);
LP_nspikes = NaN(N,1);
LP_durations = NaN(N,1);
PD_durations = NaN(N,1);
PD_burst_period_std = NaN(N,1);
LP_burst_period_std = NaN(N,1);



aPD = alldata.PD;
aLP = alldata.LP;

parfor i = 1:N
	PD = aPD(i,:);
	LP = aLP(i,:);

	offset = nanmin([PD(:); LP(:)]);

	PD = PD - offset;
	LP = LP - offset;


	[PD_burst_starts, PD_burst_stops] = embedding.findBurstStartsStopsUsingISIs(PD);
	[LP_burst_starts, LP_burst_stops] = embedding.findBurstStartsStopsUsingISIs(LP);

	PD_burst_periods = diff(PD_burst_starts);
	LP_burst_periods = diff(LP_burst_starts);

	PD_n_spikes = NaN;
	LP_n_spikes = NaN;


	LP_delays = PD_burst_starts*NaN;
	LP_off_delays = PD_burst_starts*NaN;
	PD_delays = LP_burst_starts*NaN;

	LP_durations = LP_burst_starts*NaN;
	PD_durations = PD_burst_starts*NaN;


	% measure duty cycles
	for j = 1:length(PD_durations)-1
		next_PD_stop = PD_burst_stops(find(PD_burst_stops>=PD_burst_starts(j) & PD_burst_stops<PD_burst_starts(j+1),1,'first'));
		if isempty(next_PD_stop)
			continue
		end
		PD_durations(j) = next_PD_stop - PD_burst_starts(j);
	end

	for j = 1:length(LP_durations)-1
		next_LP_stop = LP_burst_stops(find(LP_burst_stops>=LP_burst_starts(j) & LP_burst_stops<LP_burst_starts(j+1),1,'first'));
		if isempty(next_LP_stop)
			continue
		end
		LP_durations(j) = next_LP_stop - LP_burst_starts(j);
	end



	% measure LP delay in PD time
	for j = 1:length(LP_delays)-1
		next_LP_start = LP_burst_starts(find(LP_burst_starts>PD_burst_starts(j),1,'first'));
		if isempty(next_LP_start)
			continue
		end
		LP_delays(j) = next_LP_start - PD_burst_starts(j);
	end


	% LP off delays
	for j = 1:length(LP_off_delays)-1
		next_LP_stop = LP_burst_stops(find(LP_burst_stops>PD_burst_starts(j),1,'first'));
		if isempty(next_LP_stop)
			continue
		end
		LP_off_delays(j) = next_LP_stop - PD_burst_starts(j);
	end

	% measure PD delay in LP time
	for j = 1:length(PD_delays)-1
		next_PD_start = PD_burst_starts(find(PD_burst_starts>LP_burst_starts(j),1,'first'));
		if isempty(next_PD_start)
			continue
		end
		PD_delays(j) = next_PD_start - LP_burst_starts(j);
	end



	LP_phases = LP_delays(1:end-1)./PD_burst_periods;
	LP_phases_off = LP_off_delays(1:end-1)./PD_burst_periods;
	PD_phases = PD_delays(1:end-1)./LP_burst_periods;

	LP_dc = LP_durations(1:end-1)./LP_burst_periods;
	PD_dc = PD_durations(1:end-1)./PD_burst_periods;



	PD_burst_period(i) = nanmean(PD_burst_periods);
	LP_burst_period(i) = nanmean(LP_burst_periods);

	PD_burst_period_std(i) = nanstd(PD_burst_periods);
	LP_burst_period_std(i) = nanstd(LP_burst_periods);

	PD_duty_cycle(i) = nanmean(PD_dc);
	LP_duty_cycle(i) = nanmean(LP_dc);

	LP_delay_on(i) = nanmean(LP_delays);
	PD_delay_on(i) = nanmean(PD_delays);
	LP_phase_on(i) = nanmean(LP_phases);
	PD_phase_on(i) = nanmean(PD_phases);

	PD_burst_starts(isnan(PD_burst_starts)) = [];
	LP_burst_starts(isnan(LP_burst_starts)) = [];

	if length(PD_burst_starts)>1
		PD_n_spikes = histcounts(PD,PD_burst_starts);

	end
	
	if length(LP_burst_starts)>1
		LP_n_spikes = histcounts(LP,LP_burst_starts);

	end

	LP_nspikes(i) = nanmean(LP_n_spikes);
	PD_nspikes(i) = nanmean(PD_n_spikes);

	LP_delay_off(i) = nanmean(LP_off_delays);
	LP_phase_off(i) = nanmean(LP_phases_off);
	LP_durations(i) = nanmean(LP_durations);
	PD_durations(i) = nanmean(PD_durations);


end

p.PD_burst_period = PD_burst_period;
p.PD_duty_cycle = PD_duty_cycle;
p.LP_burst_period = LP_burst_period;
p.LP_duty_cycle = LP_duty_cycle;
p.LP_delay_on = LP_delay_on;
p.LP_delay_off = LP_delay_off;
p.LP_phase_off = LP_phase_off;
p.LP_phase_on = LP_phase_on;
p.PD_nspikes = PD_nspikes;
p.LP_nspikes = LP_nspikes;
p.LP_durations = LP_durations;
p.PD_durations = PD_durations;
p.PD_burst_period_std = PD_burst_period_std;
p.LP_burst_period_std = LP_burst_period_std;


