% returns a categorical vector of the modulator used
% for each experiment

function ModulatorUsed = modulatorUsedByPrep(data)


arguments
	data (1,1) embedding.DataStore
end

unique_preps = unique(data.experiment_idx);
ModulatorUsed = unique_preps;
ModulatorUsed(:) = categorical(NaN);



modulators = sourcedata.modulators;

for i = 1:length(ModulatorUsed)

	for modulator = List(modulators)
		if any(data.(modulator)(data.experiment_idx == unique_preps(i)))
			ModulatorUsed(i) = categorical({modulator});
		end
	end

end

ModulatorUsed = removecats(ModulatorUsed);