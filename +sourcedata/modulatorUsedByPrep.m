% returns a categorical vector of the modulator used
% for each experiment

function [ModulatorUsed, PrepName] = modulatorUsedByPrep(data)


arguments
	data (1,1) embedding.DataStore
end

PrepName = unique(data.experiment_idx);
ModulatorUsed = PrepName;
ModulatorUsed(:) = categorical(NaN);


modulators = sourcedata.modulators;

for i = 1:length(ModulatorUsed)

	for modulator = List(modulators)
		if any(data.(modulator)(data.experiment_idx == PrepName(i)))
			ModulatorUsed(i) = categorical({modulator});
		end
	end

end

ModulatorUsed = removecats(ModulatorUsed);
