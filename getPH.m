function pH = getPH(obj, options)

channel = find(strcmpi(obj.builtin_channel_names,'ph'));


if isempty(channel)
	error('pH  channel not found')
end

pH = obj.raw_data(:,channel);

S = round(options.dt/obj.dt);
pH = pH(1:S:end);