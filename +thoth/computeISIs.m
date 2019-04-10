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



% compute isis ans cross isis
for i = 1:length(neurons)
	for j = 1:length(neurons)
		fn = [neurons{i} '_' neurons{j}];

		data.(fn) = [];

		N = size(data.(neurons{i}),2);

		if i == j
			spiketimes = data.(neurons{i});
			isis = [diff(spiketimes);  NaN(1,N)] ;
		else
			spiketimesA = data.(neurons{i});
			spiketimesB = data.(neurons{j});


			% do it for each row separately
			all_isis = NaN(1e3,size(spiketimesA,2));

			for ii = 1:size(spiketimesA,2)

				sA = spiketimesA(:,ii);
				sB = spiketimesB(:,ii);


				isis = NaN(1e3,1);


				for k = length(sA):-1:1
					temp = sA(k) - sB;
					temp(temp<0) = Inf;

					if isempty(temp)
						isis(k) = Inf;
					else
						isis(k) = min(temp);
					end
				end

				all_isis(:,ii) = isis;

			end
			isis = all_isis;


		end

		data.(fn) = isis;

	end
end
