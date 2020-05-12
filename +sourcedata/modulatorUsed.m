% returns a categorical vector of the modulator used
% for each experiment

function m = modulatorUsed(data)


m = repmat(categorical(NaN),length(data),1);


mods = setdiff(fieldnames(data),sourcedata.defaultfields);

for i = 1:length(data)

	for j = 1:length(mods)
		if any(data(i).(mods{j}))
			m(i) = categorical(mods(j));
		end
	end

end

