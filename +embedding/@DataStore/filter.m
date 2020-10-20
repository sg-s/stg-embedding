% filters data according to some criteria

function data = filter(data, FilterSpec)

arguments
	data embedding.DataStore
	FilterSpec (1,1) sourcedata.DataFilter
end



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


	assert(min(data.mask) == 1,'Expected all data to be mask-free, but this not the case. First filter with the "AllUsable" filter');


	modulators = sourcedata.modulators;


	% remove data where more than 1 neuromodulator is used
	% at the same time
	N_mod = zeros(length(data.mask),1);
	for modulator = List(modulators)
		N_mod = N_mod + data.(modulator)>0;
	end
	if any(N_mod>1)
		data = data.purge(N_mod>1);
	end


	% remove data where no modulator is used
	unique_exps = unique(data.experiment_idx);
	rm_this = true(length(unique_exps),1);

	for i = 1:length(unique_exps)
		for modulator = List(modulators)
			if any(data.(modulator)(data.experiment_idx == unique_exps(i)))
				rm_this(i) = false;
				break
			end
		end
	end
	bad_preps = unique_exps(rm_this);
	data = data.purge(ismember(data.experiment_idx,bad_preps));



	% OK now we have a list of preps where modulator was used at some point in time
	unique_exps = unique(data.experiment_idx);
	bad_preps = true(length(unique_exps),1);

	for i = 1:length(unique_exps)

		thisdata = data.slice(data.experiment_idx == unique_exps(i));


		% prep should be decentralized at some point with no modulator
		if ~any(~thisdata.modulator & thisdata.decentralized)
			continue
		end

		% prep should be not-decentralized with no modulator 
		if ~any(~thisdata.modulator & ~thisdata.decentralized)
			continue
		end

		% prep should be decentralized and have modulator on it
		if ~any(thisdata.modulator & thisdata.decentralized)
			continue
		end

		bad_preps(i) = false;

	end

	data = data.purge(ismember(data.experiment_idx,unique_exps(bad_preps)));



	% remove preps where the baseline is really weird. 
	unique_exps = unique(data.experiment_idx);
	p_normal = zeros(length(unique_exps),1);
	for i = 1:length(unique_exps)
		temp = data.idx(data.experiment_idx == unique_exps(i) & data.decentralized == false);
		if length(temp) > 30
			temp = temp(end-29:end);
		end
		p_normal(i) = mean(temp == 'normal');
	end

	data = data.purge(ismember(data.experiment_idx,unique_exps(p_normal<.8)));



	% finally, we remove all data where the non-maximum value of the modulator was used. 
	unique_exps = unique(data.experiment_idx);
	rm_this = false(length(data.mask),1);
	for i = 1:length(unique_exps)
		for modulator = List(modulators)
			this_exp = find(data.experiment_idx == unique_exps(i));
			this_mod_values = data.(modulator)(this_exp);
			rm_these = this_exp(this_mod_values > 0 & this_mod_values < max(this_mod_values));
			rm_this(rm_these) = true;
		end
	end

	data = data.purge(rm_this);






case sourcedata.DataFilter.Baseline



	rm_this = data.temperature < 10 | data.temperature > 12;
	data = purge(data,rm_this);
	


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
	assert(isscalar(data),'expected data to be scalar')
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