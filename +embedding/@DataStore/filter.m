% filters data according to some criteria

function data = filter(data, FilterSpec)

arguments
	data embedding.DataStore
	FilterSpec (1,1) sourcedata.DataFilter
end



switch FilterSpec



case sourcedata.DataFilter.AllUsable

	% This throws out the following data:
	% masked data
	% PTX data
	% TTX data
	% unusable data


	for i = 1:length(data)
		data(i) = data(i).purge(~data(i).mask);
		data(i) = data(i).purge(data(i).PTX > 0);
		data(i) = data(i).purge(data(i).TTX > 0);
		data(i) = data(i).purge(data(i).unusable);
	end
	data(cellfun(@sum,{data.mask}) == 0) = [];



case sourcedata.DataFilter.Neuromodulator


	assert(min(data.mask) == 1,'Expected all data to be mask-free, but this not the case. First filter with the "AllUsable" filter');
	assert(length(data)==1,'Expected a scalar DataStore. Use "combine" first')


	modulators = sourcedata.modulators;


	% remove data where more than 1 neuromodulator is used
	% at the same time
	N_mod = zeros(length(data.mask),1);
	for modulator = List(modulators)
		N_mod = N_mod + double(data.(modulator)>0);
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



	% remove preps where the baseline is really weird ( defined as spending more than 20% of its time in non-normal states just before decentralization). This should allow for some transient behaviour which might emerge from the stress of early prep. handling
	% unique_exps = unique(data.experiment_idx);
	% p_normal = zeros(length(unique_exps),1);
	% for i = 1:length(unique_exps)
	% 	temp = data.idx(data.experiment_idx == unique_exps(i) & data.decentralized == false);
	% 	if length(temp) > 30
	% 		temp = temp(end-29:end);
	% 	end
	% 	p_normal(i) = mean(temp == 'normal' | temp == 'LP-weak-skipped' | temp == 'aberrant-spikes');
	% end

	% data = data.purge(ismember(data.experiment_idx,unique_exps(p_normal<.5)));



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

	assert(isscalar(data),'expected data to be scalar')
	assert(min(data.mask)==1,'Some data is masked, are you sure this data has gone through the AllUsable filter?')

	rm_this = data.temperature < 10 | data.temperature > 12;
	data = purge(data,rm_this);
	


	



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
	% AllUsable filter and been combined
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


	% remove preps where the baseline is really weird ( defined as spending more than 20% of its time in non-normal states just before decentralization). This should allow for some transient behaviour which might emerge from the stress of early prep. handling
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




otherwise
	error('Unknown FilterSpec')

end