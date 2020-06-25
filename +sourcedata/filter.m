% filters data according to some criteria

function outdata = filter(data, FilterSpec)

switch FilterSpec


case sourcedata.DataFilter.Neuromodulator

	% remove data where no modulator is used
	modulator = sourcedata.modulatorUsed(data);
	data = data(~isundefined(modulator));
	modulator = modulator(~isundefined(modulator));


	% first, remove all pieces of data that are not at 11C
	for i = 1:length(data)
	end

	
	rm_this = false(length(data),1);
	for i = 1:length(data)

		% prep should be decentralized at some point with no modulator
		if ~any(data(i).(char(modulator(i))) == 0 & data(i).decentralized)
			rm_this(i) = true;
		end

		% prep should be not-decentralized with no modulator 
		if ~any(~data(i).decentralized & data(i).(char(modulator(i))) == 0)
			rm_this(i) = true;
		end

		% prep should be decentralized and have modulator on it 
		if  ~any(data(i).decentralized & data(i).(char(modulator(i))))
			rm_this(i) = true;
		end


	end

	keyboard

case sourcedata.DataFilter.Baseline
	keyboard
otherwise
	error('Unknown FilterSpec')

end