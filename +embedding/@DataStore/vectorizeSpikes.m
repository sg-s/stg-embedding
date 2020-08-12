% converts spiketimes into a vectorized representation
% using nominal burst starts and ends
% which are in turn estimated by their position
% relative to the other neuron

function [Metrics, NMetrics, VectorizedData] = vectorizeSpikes(alldata)


assert(length(alldata)==1,'Expected DataStore to be scalar')


N = length(alldata.mask);
neurons = {'PD','LP'};


% placeholders
p.PD_burst_period_mean = NaN(N,1);
p.PD_burst_period_cv = NaN(N,1);
p.PD_burst_period_max = NaN(N,1);
p.PD_burst_period_min = NaN(N,1);

p.LP_burst_period_mean = NaN(N,1);
p.LP_burst_period_cv = NaN(N,1);
p.LP_burst_period_max = NaN(N,1);
p.LP_burst_period_min = NaN(N,1);

p.LP_phase_mean = NaN(N,1);
p.LP_phase_cv = NaN(N,1);
p.LP_phase_max = NaN(N,1);
p.LP_phase_min = NaN(N,1);

p.PD_phase_mean = NaN(N,1);
p.PD_phase_cv = NaN(N,1);
p.PD_phase_max = NaN(N,1);
p.PD_phase_min = NaN(N,1);


p.LP_dc_mean = NaN(N,1);
p.LP_dc_cv = NaN(N,1);
p.LP_dc_max = NaN(N,1);
p.LP_dc_min = NaN(N,1);

p.PD_dc_mean = NaN(N,1);
p.PD_dc_cv = NaN(N,1);
p.PD_dc_max = NaN(N,1);
p.PD_dc_min = NaN(N,1);


% ratio of LP to PD periods
p.PeriodError = NaN(N,1);


% ratio of periods from burst ends and burst starts
p.LP_period_error = NaN(N,1);
p.PD_period_error = NaN(N,1);


p.PD_isi_max = NaN(N,1);
p.LP_isi_max = NaN(N,1);
% p.PD_isi_min = nanmin(alldata.PD_PD,[],2);
% p.LP_isi_min = nanmin(alldata.LP_LP,[],2);


% ratio of max of 2nd to max of 1st order ISI
p.PD_second_order = NaN(N,1);
p.LP_second_order = NaN(N,1);


% max of ratios of ISIs (1st./2...5th)
p.PD_isi_ratios = NaN(N,1);
p.LP_isi_ratios = NaN(N,1);



% also firing rates
p.PDf = sum(~isnan(alldata.PD),2);
p.LPf = sum(~isnan(alldata.LP),2);



PD_burst_periods2 = NaN(N,1);
LP_burst_periods2 = NaN(N,1);

disp('Computing burst starts and stops...')

for i = 1:N

	corelib.textbar(i,N)

	PD = alldata.PD(i,:);
	LP = alldata.LP(i,:);

	[PD_burst_starts, PD_burst_stops] = embedding.findNominalBurstStartsStops(PD,LP);
	[LP_burst_starts, LP_burst_stops] = embedding.findNominalBurstStartsStops(LP,PD);





	% figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
	% neurolib.raster(alldata.PD(i,:),'deltat',1,'center',false,'yoffset',0)
	% neurolib.raster(alldata.LP(i,:),'deltat',1,'center',false,'yoffset',1)
	% plot(LP_burst_starts,LP_burst_starts*0+1.95,'gd')
	% plot(LP_burst_stops,LP_burst_stops*0+1.95,'rd')

	% plot(PD_burst_starts,PD_burst_starts*0+.95,'gd')
	% plot(PD_burst_stops,PD_burst_stops*0+.95,'rd')

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


	PD_burst_periods = diff(PD_burst_starts);
	LP_burst_periods = diff(LP_burst_starts);

	PD_burst_periods2(i) = nanmean(diff(PD_burst_stops));
	LP_burst_periods2(i) = nanmean(diff(LP_burst_stops));


	LP_phases(1:end-1) = LP_phases(1:end-1)./PD_burst_periods;
	PD_phases(1:end-1) = PD_phases(1:end-1)./LP_burst_periods;

	LP_dc(1:end-1) = LP_dc(1:end-1)./LP_burst_periods;
	PD_dc(1:end-1) = PD_dc(1:end-1)./PD_burst_periods;
	

	if i == 4976
		keyboard
	end



	p.PD_burst_period_mean(i) = nanmean(PD_burst_periods);
	p.PD_burst_period_cv(i) = nanstd(PD_burst_periods);
	p.PD_burst_period_max(i) = nanmax(PD_burst_periods);
	p.PD_burst_period_min(i) = nanmin(PD_burst_periods);


	p.LP_burst_period_mean(i) = nanmean(LP_burst_periods);
	p.LP_burst_period_cv(i) = nanstd(LP_burst_periods);
	p.LP_burst_period_max(i) = nanmax(LP_burst_periods);
	p.LP_burst_period_min(i) = nanmin(LP_burst_periods);


	p.PD_phase_mean(i) = nanmean(PD_phases);
	p.PD_phase_cv(i) = nanstd(PD_phases);
	p.PD_phase_max(i) = nanmax(PD_phases);
	p.PD_phase_min(i) = nanmin(PD_phases);
	

	p.LP_phase_mean(i) = nanmean(LP_phases);
	p.LP_phase_cv(i) = nanstd(LP_phases);
	p.LP_phase_max(i) = nanmax(LP_phases);
	p.LP_phase_min(i) = nanmin(LP_phases);


	p.PD_dc_mean(i) = nanmean(PD_dc);
	p.PD_dc_cv(i) = nanstd(PD_dc);
	p.PD_dc_max(i) = nanmax(PD_dc);
	p.PD_dc_min(i) = nanmin(PD_dc);
	

	p.LP_dc_mean(i) = nanmean(LP_dc);
	p.LP_dc_cv(i) = nanstd(LP_dc);
	p.LP_dc_max(i) = nanmax(LP_dc);
	p.LP_dc_min(i) = nanmin(LP_dc);
end

% compare burst periods from burst starts and burst ends
p.PD_period_error = 2*abs(PD_burst_periods2 - p.PD_burst_period_mean)./(PD_burst_periods2 + p.PD_burst_period_mean);
p.LP_period_error = 2*abs(LP_burst_periods2 - p.LP_burst_period_mean)./(LP_burst_periods2 + p.LP_burst_period_mean);



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

% cap the ratios
p.PD_isi_ratios(p.PD_isi_ratios>3)=  3;
p.LP_isi_ratios(p.LP_isi_ratios>3)=  3;


% phases beyond [0 1] are meaningless
p.PD_phase_mean(p.PD_phase_mean>1) = NaN;
p.PD_phase_max(p.PD_phase_max>1) = NaN;
p.PD_phase_min(p.PD_phase_min>1) = NaN;
p.LP_phase_mean(p.LP_phase_mean>1) = NaN;
p.LP_phase_max(p.LP_phase_max>1) = NaN;
p.LP_phase_min(p.LP_phase_min>1) = NaN;

% duty cycles beyond 1 are meaningless
p.PD_dc_mean(p.PD_dc_mean>1) = NaN;
p.PD_dc_max(p.PD_dc_max>1) = NaN;
p.PD_dc_min(p.PD_dc_min>1) = NaN;
p.LP_dc_mean(p.LP_dc_mean>1) = NaN;
p.LP_dc_max(p.LP_dc_max>1) = NaN;
p.LP_dc_min(p.LP_dc_min>1) = NaN;


% actually get the CV instead of the std
p.LP_burst_period_cv = p.LP_burst_period_cv./p.LP_burst_period_mean;
p.PD_burst_period_cv = p.PD_burst_period_cv./p.PD_burst_period_mean;

p.LP_phase_cv = p.LP_phase_cv./p.LP_phase_mean;
p.PD_phase_cv = p.PD_phase_cv./p.PD_phase_mean;


p.PeriodError = 2+abs(p.PD_burst_period_mean - p.LP_burst_period_mean)./(p.PD_burst_period_mean + p.LP_burst_period_mean);

Metrics = p;
NMetrics = Metrics;

% normalize 
fn = fieldnames(NMetrics);
for i = 1:length(fn)
	M = nanmean(NMetrics.(fn{i}));
	S = nanstd(NMetrics.(fn{i}));
	NMetrics.(fn{i}) = NMetrics.(fn{i}) - M;
	NMetrics.(fn{i}) = NMetrics.(fn{i})/S;
end


% handle missing data and exceptions 


% burst periods
NMetrics.PD_burst_period_mean(isnan(NMetrics.PD_burst_period_mean)) = -10;
NMetrics.LP_burst_period_mean(isnan(NMetrics.LP_burst_period_mean)) = -10;
NMetrics.PD_burst_period_min(isnan(NMetrics.PD_burst_period_min)) = -10;
NMetrics.LP_burst_period_min(isnan(NMetrics.LP_burst_period_min)) = -10;
NMetrics.PD_burst_period_max(isnan(NMetrics.PD_burst_period_max)) = -10;
NMetrics.LP_burst_period_max(isnan(NMetrics.LP_burst_period_max)) = -10;



% phases
NMetrics.PD_phase_max(isnan(NMetrics.PD_phase_max)) = -1;
NMetrics.LP_phase_max(isnan(NMetrics.LP_phase_max)) = -1;
NMetrics.PD_phase_min(isnan(NMetrics.PD_phase_min)) = 2;
NMetrics.LP_phase_min(isnan(NMetrics.LP_phase_min)) = 2;
NMetrics.PD_phase_mean(isnan(NMetrics.PD_phase_mean)) = -1;
NMetrics.LP_phase_mean(isnan(NMetrics.LP_phase_mean)) = -1;


% duty cycles
NMetrics.PD_dc_max(isnan(NMetrics.PD_dc_max)) = -1;
NMetrics.LP_dc_max(isnan(NMetrics.LP_dc_max)) = -1;
NMetrics.PD_dc_min(isnan(NMetrics.PD_dc_min)) = 2;
NMetrics.LP_dc_min(isnan(NMetrics.LP_dc_min)) = 2;
NMetrics.PD_dc_mean(isnan(NMetrics.PD_dc_mean)) = -1;
NMetrics.LP_dc_mean(isnan(NMetrics.LP_dc_mean)) = -1;



% fill in NaNs in some fields with the maximum value,
% because higher values = "bad" in these fields
fields = {'PeriodError','PD_isi_max','LP_isi_max','PD_isi_ratios','LP_isi_ratios','PD_second_order','LP_second_order','PD_period_error','LP_period_error','PD_dc_cv','LP_dc_cv','PD_phase_cv','LP_phase_cv','PD_burst_period_cv','LP_burst_period_cv'};
for i = 1:length(fields)
	NMetrics.(fields{i}) = embedding.nan2max(NMetrics.(fields{i}));
end




VectorizedData = struct2array(NMetrics);