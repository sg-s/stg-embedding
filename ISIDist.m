% computes distance between data structures containing spikes

function D = ISIDist(data,neuron_names)

D = zeros(length(data));

% check that neuron names are valid
assert(iscell(neuron_names),'neuron_names should be a cell array')
for i = 1:length(neuron_names)
	for j = 1:length(neuron_names)
		assert(isfield(data,[neuron_names{j} '_' neuron_names{j}]),'field did not resolve')
	end
end



for a = 1:length(data)
	corelib.textbar(a,length(data))
	X = data(a);
	for b = 1:length(data)
		
		Y = data(b);

		for i = 1:length(neuron_names)
			for j = 1:length(neuron_names)



				ISI_A = X.([neuron_names{j} '_' neuron_names{j}]);
				ISI_B = Y.([neuron_names{j} '_' neuron_names{j}]);


			
				D(a,b) = D(a,b) + ISIDist_core(ISI_A,ISI_B);

			end
		end
	end
end






