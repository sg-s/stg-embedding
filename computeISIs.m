% computes ISIs and cross-ISIs for given spike data

function data = computeISIs(data, neurons)



% check that everything in the neuron list is there in the data
for i = 1:length(neurons)
	assert(isfield(data,neurons{i}),'Neuron does not exist in data')
end

% make placeholders
% compute ISIs for all neurons
for i = 1:length(neurons)
	for j = 1:length(neurons)
		fn = [neurons{i} '_' neurons{j}];
		data(1).(fn) = [];
	end
end


% handle each bit of the data indepndently
if length(data) > 1

	parfor i = 1:length(data)
		data(i) = computeISIs(data(i), neurons);
	end
	return
end




% compute isis ans cross isis
for i = 1:length(neurons)
	for j = 1:length(neurons)
		fn = [neurons{i} '_' neurons{j}];

		data.(fn) = [];
		if i == j
			spiketimes = data.(neurons{i});
			isis = diff(spiketimes);
		else
			spiketimesA = data.(neurons{i});
			spiketimesB = data.(neurons{j});

			isis = NaN(length(spiketimesA),1);


			for k = length(spiketimesA):-1:1
				temp = spiketimesA(k) - spiketimesB;
				temp(temp<0) = Inf;
				if isempty(temp)
					isis(k) = Inf;
				else
					isis(k) = min(temp);
				end
				

			end

		end

		data.(fn) = isis;

	end
end
