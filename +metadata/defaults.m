% specifies default values of metadata fields,
% used to populate metadata when missing or NaN

function d = defaults()

d.temperature = 11;
d.Potassium = 1;

m = sourcedata.modulators;

for i = 1:length(m)
	d.(m{i}) = 0;
end

d.decentralized = false;
d.PTX = 0;
d.TTX = 0;
d.tetraethlyammonium = 0;