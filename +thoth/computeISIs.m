% computes ISIs and cross-ISIs for given spike data

function data = computeISIs(data, neurons)

% use parallel pool to accelerate computation on more than 1 dataset
if length(data) > 1

	% add placeholder fields
	for k = 1:length(data)
		for i = 1:length(neurons)
			for j = 1:length(neurons)
				fn = [neurons{i} '_' neurons{j}];
				data(k).(fn) = [];
			end
		end
	end


	parfor i = 1:length(data)
		data(i) = thoth.computeISIs(data(i),neurons);
	end

	return
end


% check that everything in the neuron list is there in the data
for i = 1:length(neurons)
	assert(isfield(data,neurons{i}),'Neuron does not exist in data')
end

% make placeholders
% compute ISIs for all neurons
for i = 1:length(neurons)
	for j = 1:length(neurons)
		fn = [neurons{i} '_' neurons{j}];
		data.(fn) = [];
	end
end

% compute isis and cross isis
for i = 1:length(neurons)
	for j = 1:length(neurons)
		fn = [neurons{i} '_' neurons{j}];

		data.(fn) = [];

		N = size(data.(neurons{i}),2);

		if i == j
			% simple ISIs, easy to compute
			spiketimes = sort(data.(neurons{i}));
			isis = [diff(spiketimes);  NaN(1,N)] ;
		else
			% cross ISIs
			spiketimesA = sort(data.(neurons{i}));
			spiketimesB = sort(data.(neurons{j}));

			% do it for each row separately
			all_isis = NaN(1e3,size(spiketimesA,2));

			parfor ii = 1:size(spiketimesA,2)

				sA = spiketimesA(:,ii);
				sB = spiketimesB(:,ii);


				isis = NaN(1e3,1);


				for k = length(sA):-1:1

					nextAspike = sA(find(sA>sA(k),1,'first'));
					nextBspike = sB(find(sB>sA(k),1,'first'));

					if isempty(nextBspike)
						% no next B spike, ISI not defined
						continue
					end

					if isempty(nextAspike)
						% no next A spike, ISI is simply defined
						isis(k) = nextBspike - sA(k);
						continue
					end

					% there is a spike in both A and B
					% ISI is defined only if nextBspike occurs
					% before nextAspike

					if nextAspike < nextBspike
						% ISI not defined
						continue
					end

					isis(k) = nextBspike - sA(k);

				end

				all_isis(:,ii) = isis;

			end
			isis = all_isis;


		end

		% check that all isis are +ve
		assert(min(isis(:))>=0,'Some ISIs are negative, which makes no sense')

		data.(fn) = isis;

	end
end

