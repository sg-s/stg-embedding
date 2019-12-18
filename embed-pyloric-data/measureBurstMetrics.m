% measure burst period, duty cycle for PD, LP

function data = measureBurstMetrics(data)


neurons = {'LP','PD'};
N = size(data.(neurons{1}),1);

min_ibi = .1;




for i = 1:length(neurons)

	data.([neurons{i} '_burst_period']) = NaN(N,1);

	for j = 1:N

		spikes = data.(neurons{i})(j,:);
		isis = diff(spikes);

		burst_ends_idx = find(isis>min_ibi);

		burst_end_times = spikes(burst_ends_idx);

		data.([neurons{i} '_burst_period'])(j) = mean(diff(burst_end_times));

	end


end
