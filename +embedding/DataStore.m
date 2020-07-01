classdef DataStore < dynamicprops

properties

	mask logical 
	LP  double
	LP_LP double
	LP_PD double
	PD_LP double
	PD_PD double
	PD double

	temperature double

	decentralized logical

	experiment_idx categorical
	experimenter categorical


	time_offset double

	LP_channel categorical
	PD_channel  categorical

	filename categorical
	

end % props


methods 


	function DS = DataStore(data)

		fn = fieldnames(data);
		p = properties(DS);
		for i = 1:length(fn)
			if ~ismember(fn{i},p)
				DS.addprop(fn{i});
			end
			DS.(fn{i}) = data.(fn{i});
		end

		% size the ISIs correctly
		fn = {'LP_LP','LP_PD','PD_LP','PD_PD'};
		for i = 1:length(fn)
			if isempty(DS.(fn{i}))
				DS.(fn{i}) = DS.PD*NaN;
			end
		end

		% make sure everything has the same size
		fn = properties(DS);
		fn = setdiff(fn,{'PD','LP','LP_PD','LP_LP','PD_PD','PD_LP'});
		for i = 1:length(fn)
			if ~all(size(DS.(fn{i})) == size(DS.mask))
				disp(DS.experiment_idx(1))
				error('Something wrong with this data')
			end
		end

	end % constructor


end % methods



methods (Static)

	function DSArray = cell2array(DSArray)

		assert(iscell(DSArray),'Input should be a cell array containing DataStore objects')
		for i = 1:length(DSArray)
			assert(isa(DSArray{i},'embedding.DataStore'),'Cell array should contain DataStore objects ant nothing else')
		end

		% get all props
		all_props = {};
		for i = 1:length(DSArray)
			all_props = unique([all_props; properties(DSArray{i})]);
		end

		for i = 1:length(DSArray)
			for j = 1:length(all_props)
				if ~isprop(DSArray{i},all_props{j})
					DSArray{i}.addprop(all_props{j});
				end
			end
		end


		DSArray = vertcat(DSArray{:});



		% now fill in the empty arrays using defaults
		defaults = metadata.defaults;
		for i = 1:length(DSArray)
			N = length(DSArray(i).mask);
			for j = 1:length(all_props)
				if isempty(DSArray(i).(all_props{j}))
					DSArray(i).(all_props{j}) = repmat(defaults.(all_props{j}),N,1);
				end
			end
		end

	end % cell2array

end % static methods


end % classdef