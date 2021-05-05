% returns a logical vector indicating when
% a modulator is applied, and also returns the identity
% of the modulator(s) used


function [TF, ModulatorUsed] = modulator(self)


arguments
	self (1,1) embedding.DataStore
end

TF = false(length(self.mask),1);

modulators = sourcedata.modulators;
ModulatorUsed = {};
for modulator = List(modulators)
	if any(self.(modulator))
		TF = TF | logical(self.(modulator));
		ModulatorUsed = [ModulatorUsed; modulator];
	end

end

