% converts isis to dominant period
% in a parameter-free manner

function [metrics] = ISI2DominantPeriod(spikes,isis)

T = NaN(size(isis,1),1);
ACF_values = T;
FailureMode = zeros(length(T),1);
NormPeriodRange = T;

T_mismatch = zeros(length(T),1)+10;

time = linspace(0,20,2e3);

NSpikesMean = T;
NSpikesVar = T;

parfor i = 1:length(T)
%for i = 1030


	this_isis = isis(i,~isnan(isis(i,:)));
	this_isis(this_isis==0) = [];


	if length(this_isis) < 2
		% no ISIs -> no spikes
		FailureMode(i) = 1;
		continue
	end

	this_spikes = spikes(i,~isnan(spikes(i,:)));
	this_spikes = this_spikes(1:length(this_isis));

	assert(max(this_spikes) < 21,'Spikes longer than 20 seconds??')


	if min(this_spikes) > max(this_isis)
		% there's an empty stretch in the beginning. let's make sure 
		% we don't ignore it
		this_spikes = [0 this_spikes];
		this_isis = [this_spikes(2) this_isis];
	end

	last_spike = max(this_spikes);
	if last_spike <(20-max(this_isis))
		% suspcious empty stretch at end
		this_spikes = [this_spikes 20];
		this_isis = [this_isis 20-last_spike];
	end


	if length(unique(this_spikes) ~= length(unique(this_spikes)))
		[this_spikes, idx]=unique(this_spikes);
		this_isis = this_isis(idx);
	end
	Y = interp1(this_spikes,this_isis,time);
	

	if sum(~isnan(Y)) < 501
		FailureMode(i) = 2;
		continue
	end

	acf = autocorr(Y,500); % 5 seconds


	FirstZeroCrossing = find(acf<0,1,'first');

	if isempty(FirstZeroCrossing)
		FailureMode(i) = 3;
		continue
	end

	SecondZeroCrossing = find(acf(FirstZeroCrossing+1:end)>0,1,'first') + FirstZeroCrossing;


	if isempty(SecondZeroCrossing)
		FailureMode(i) = 4;
		continue
	end

	ThirdZeroCrossing = find(acf(SecondZeroCrossing+1:end)<0,1,'first') + SecondZeroCrossing;

	if isempty(ThirdZeroCrossing)
		FailureMode(i) = 5;
		continue
	end

	[ACF_values(i),idx]=max(acf(SecondZeroCrossing:ThirdZeroCrossing));
	T(i) = idx + SecondZeroCrossing - 1;


	% find all peaks
	[~,peak_locs] = findpeaks(Y,'MinPeakHeight',T(i)/300,'MinPeakDistance',T(i)/2);


	% if max(peak_locs) < (2000-T(i)*2)
	% 	% some peaks are missing...something happens in the later part 
	% 	peak_locs = [peak_locs 2000];
	% end


	all_T = diff(peak_locs);
	if isempty(all_T)
		FailureMode(i) = 6;
		continue
	end
	NormPeriodRange(i) = (max(all_T)-min(all_T))/median(all_T);


	T_mismatch(i) = abs(mean(all_T)-T(i))/T(i);

	NSpikesPerBurst = diff(find(this_isis>=min(Y(peak_locs))));


	if ~isempty(NSpikesPerBurst)
		NSpikesMean(i) = mean(NSpikesPerBurst);
		NSpikesVar(i) = (max(NSpikesPerBurst) - min(NSpikesPerBurst))/median(NSpikesPerBurst);
	end


end

% get units right
T = T/100; % in seconds
T(isnan(T)) = 20;


T_mismatch = erf(T_mismatch);

metrics.DominantPeriod = T;
metrics.T_mismatch = T_mismatch;
metrics.NSpikesVar = NSpikesVar;
metrics.NSpikesMean = NSpikesMean;
metrics.NormPeriodRange = NormPeriodRange;
metrics.ACF_values = ACF_values;