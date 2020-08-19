% filters data according to some criteria

function data = filter(data, FilterSpec)


assert(isa(FilterSpec,'sourcedata.DataFilter'),'Filter needs to be of type sourcedata.DataFilter')


switch FilterSpec



case sourcedata.DataFilter.AllUsable


	% purge masked data
	for i = 1:length(data)
		data(i) = data(i).purge(~data(i).mask);
	end


	% remove empty datasets
	data(cellfun(@sum,{data.mask}) == 0) = [];


	% first, remove all pieces of data that are not at 11C
	for i = 1:length(data)
		% except if it's Philipp's data
		if data(i).experimenter(1) == 'rosenbaum'
			continue
		end
		rm_this = data(i).temperature < 10 | data(i).temperature > 15;
		data(i) = purge(data(i),rm_this);
	end



	% remove empty datasets
	data(cellfun(@sum,{data.mask}) == 0) = [];


	% remove non-default values for things
	defaults = rmfield(embedding.DataStore.defaults,'decentralized');
	defaults = rmfield(defaults,'temperature');
	defaults = rmfield(defaults,'baseline');
	defaults = rmfield(defaults,sourcedata.modulators);

	fn = fieldnames(defaults);

	for i = 1:length(data)
		rm_this = false(length(data(i).mask),1);
		for j = 1:length(fn)
			rm_this(data(i).(fn{j}) ~= defaults.(fn{j})) = true;
		end
		data(i) = purge(data(i),rm_this);
	end


	% remove empty datasets
	data(cellfun(@sum,{data.mask}) == 0) = [];



case sourcedata.DataFilter.Neuromodulator


	error('Not coded')

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






case sourcedata.DataFilter.Baseline


	assert(isscalar(data),'expected data to be scalar')
	assert(min(data.mask)==1,'Some data is masked, are you sure this data has gone through the AllUsable filter?')



	% remove anything that has a non-default value	
	defaults = rmfield(embedding.DataStore.defaults,'temperature');
	fn = fieldnames(defaults);


	rm_this = false(length(data.mask),1);
	for j = 1:length(fn)
		rm_this(data.(fn{j}) ~= defaults.(fn{j})) = true;
	end

	data = purge(data,rm_this);


	% purge data with undefined experiment IDs. WTF??
	data = purge(data,isundefined(data.experiment_idx));







case sourcedata.DataFilter.Decentralized


	% assume we are working with scalar data, because
	% filtering is expected to happen after we combine all the data
	% and embed it
	% so we also assume that it has already gone through the 
	% AllUsable filter
	assert(isscalar(data),'expecteded data to be scalar')
	assert(min(data.mask)==1,'Some data is masked, are you sure this data has gone through the AllUsable filter?')





	% remove anything that has a non-default value
	defaults = rmfield(embedding.DataStore.defaults,'decentralized');
	defaults = rmfield(defaults,'temperature');
	defaults = rmfield(defaults,'baseline');

	fn = fieldnames(defaults);

	rm_this = false(length(data.mask),1);
	for j = 1:length(fn)
		rm_this(data.(fn{j}) ~= defaults.(fn{j})) = true;
	end
	data = purge(data,rm_this);


	% purge data with undefined experiment IDs. WTF??
	data = purge(data,isundefined(data.experiment_idx));


	% make sure every prep is decentralized at some point, and is 
	% intact at some point
	all_exps = unique(data.experiment_idx);
	rm_these_exps = false(length(all_exps),1);
	for i = 1:length(all_exps)
		this_dec = data.decentralized(data.experiment_idx == all_exps(i));
		if max(this_dec) == 1 & min(this_dec) == 0
			continue
		end
		rm_these_exps(i) = true;
	end


	rm_this = false(length(data.mask),1);
	for i = 1:length(all_exps)
		if rm_these_exps(i)
			rm_this(data.experiment_idx == all_exps(i)) = true;

		end
	end

	data = purge(data,rm_this);


otherwise
	error('Unknown FilterSpec')

end