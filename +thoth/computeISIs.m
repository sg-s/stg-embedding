% computes ISIs and cross-ISIs for given spike data

function data = computeISIs(data, neurons)

assert(length(data) == 1,'This function only works on scalar structures')

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


disp('Measuring ISIs:')
% compute isis and cross isis
for i = 1:length(neurons)
	for j = 1:length(neurons)
		fn = [neurons{i} '_' neurons{j}];

		disp(fn)

		data.(fn) = [];

		N = size(data.(neurons{i}),2);

		if i == j
			spiketimes = data.(neurons{i});
			isis = [diff(spiketimes);  NaN(1,N)] ;
		else
			% cross ISIs
			spiketimesA = data.(neurons{i});
			spiketimesB = data.(neurons{j});

			% do it for each row separately
			all_isis = NaN(1e3,size(spiketimesA,2));

			for ii = 1:size(spiketimesA,2)

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

		data.(fn) = isis;

	end
end
