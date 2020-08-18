function burst_metrics = ISI2BurstMetrics(alldata)

assert(length(alldata)==1,'Expected a scalar DataStore')

N = length(alldata.mask);

PD = alldata.PD;
LP = alldata.LP;


p.PD_burst_period = NaN(1,1);

p.PD_duty_cycle = NaN(1,1);


p.LP_burst_period = NaN(1,1);

p.LP_duty_cycle = NaN(1,1);


p.LP_delay_on = NaN(1,1);


p.LP_delay_off = NaN(1,1);
p.LP_phase_off = NaN(1,1);
p.LP_phase_on = NaN(1,1);

p.PD_nspikes = NaN(1,1);
p.LP_nspikes = NaN(1,1);

p.LP_durations = NaN(1,1);
p.PD_durations = NaN(1,1);


p = repmat(p,N,1);


for i = 1:N
	PD = alldata.PD(i,:);
	LP = alldata.LP(i,:);

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



	p(i).PD_burst_period = nanmean(PD_burst_periods);
	p(i).LP_burst_period = nanmean(LP_burst_periods);

	p(i).PD_duty_cycle = nanmean(PD_dc);
	p(i).LP_duty_cycle = nanmean(LP_dc);

	p(i).LP_delay_on = nanmean(LP_delays);

	p(i).PD_delay_on = nanmean(PD_delays);

	p(i).LP_phase_on = nanmean(LP_phases);

	p(i).PD_phase_on = nanmean(PD_phases);

	PD_burst_starts(isnan(PD_burst_starts)) = [];
	LP_burst_starts(isnan(LP_burst_starts)) = [];

	if length(PD_burst_starts)>1
		PD_n_spikes = histcounts(PD,PD_burst_starts);

	end
	
	if length(LP_burst_starts)>1
		LP_n_spikes = histcounts(LP,LP_burst_starts);

	end

	p(i).LP_nspikes = nanmean(LP_n_spikes);
	p(i).PD_nspikes = nanmean(PD_n_spikes);

	p(i).LP_delay_off = nanmean(LP_off_delays);

	p(i).LP_phase_off = nanmean(LP_phases_off);

	p(i).LP_durations = nanmean(LP_durations);


	p(i).PD_durations = nanmean(PD_durations);


end

burst_metrics = p;

