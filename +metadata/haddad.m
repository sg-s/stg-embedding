% haddad-specific functions

function data = haddad(data)

mod_names = setdiff(fieldnames(data),sourcedata.defaultfields);

for i = 1:length(data)
	if data(i).experimenter_name ~= 'haddad'
		continue
	end

	modulator = 0*data(i).mask;
	for j = 1:length(mod_names)
		a = find(data(i).(mod_names{j})>0,1,'first');
		if isempty(a)
			continue
		end
		modulator(a:end) = 1;
	end
	data(i).modulator = modulator;
end