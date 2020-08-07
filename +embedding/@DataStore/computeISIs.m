% computes ISIs and cross-ISIs for given spike data

function data = computeISIs(data)


neurons = {'LP','PD'};

assert(isscalar(data),'Expected data to be scalar')

% compute isis and cross isis
for i = 1:length(neurons)
	for j = 1:length(neurons)
		fn = [neurons{i} '_' neurons{j}];

		N = size(data.(neurons{i}),1);

		if i == j
			% simple ISIs, easy to compute
			spiketimes = data.(neurons{i});
			isis = [diff(spiketimes,[],2)  NaN(N,1)] ;
		else
			% cross ISIs
			spiketimesA = data.(neurons{i});
			spiketimesB = data.(neurons{j});

			% do it for each row separately
			all_isis = NaN(N,1e3);

			parfor ii = 1:N

				sA = spiketimesA(ii,:);
				sB = spiketimesB(ii,:);


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

				all_isis(ii,:) = isis;

			end
			isis = all_isis;


		end

		% check that all isis are +ve
		assert(min(isis(:))>=0,'Some ISIs are negative, which makes no sense')

		data.(fn) = isis;

	end
end

