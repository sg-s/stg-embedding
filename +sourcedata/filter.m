% filters data according to some criteria

function outdata = filter(data, FilterSpec)

switch FilterSpec


case sourcedata.DataFilter.Neuromodulator

	% first, remove all pieces of data that are not at 11C
	for i = 1:length(data)
		% except if it's Philipp's data
		if data(i).experimenter(1) == 'rosenbaum'
			continue
		end
		rm_this = data(i).temperature < 10 | data(i).temperature > 15;
		data(i) = sourcedata.purge(data(i),rm_this);
	end

	% remove empty datasets
	data(cellfun(@sum,{data.mask}) == 0) = [];


	% remove data where no modulator is used
	modulator = sourcedata.modulatorUsed(data);
	data = data(~isundefined(modulator));

	

	modulator = sourcedata.modulatorUsed(data);

	
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

		if rm_this(i)
			disp(data(i).experiment_idx(1))
		end



	end

	outdata = data;

case sourcedata.DataFilter.Baseline
	keyboard
otherwise
	error('Unknown FilterSpec')

end