classdef DataStore

properties


	% usability
	mask logical = true
	unusable double = 0

	% spikes and isis
	LP  double = NaN(1e3,1)
	LP_LP double = NaN(1e3,1)
	LP_PD double = NaN(1e3,1)
	PD_LP double = NaN(1e3,1)
	PD_PD double = NaN(1e3,1)
	PD double = NaN(1e3,1)

	% experimental info
	baseline double = 1
	decentralized logical = false

	temperature double = 11

	

	experiment_idx categorical = categorical(NaN)
	experimenter categorical = categorical(NaN)


	time_offset double = 0 

	LP_channel categorical  = categorical(NaN)
	PD_channel  categorical = categorical(NaN)

	filename categorical = categorical(NaN)


	pH double = 7

	% modulators, etc
	Potassium double = 1
	TTX double  = 0
	PTX double = 0
	octopamine  double = 0   
	dopamine double = 0  
	FLRFamide double = 0  
	CabTrp1a double = 0  
	TNRNFLRFamide double = 0  
	CCAP double = 0  
	serotonin double = 0  
	tetraethlyammonium double = 0  
	pilocarpine double = 0   
	proctolin double = 0  
	oxotremorine double = 0  
	atropine double = 0  
	RPCH double = 0  


end % props


methods 



	function DS = DataStore(data)

		if nargin == 0
			return
		end

		fn = fieldnames(data);
		for i = 1:length(fn)
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
		MaskSize = size(DS.mask,1);
		for i = 1:length(fn)
			SZ = size(DS.(fn{i}),1);

			if SZ == 1
				DS.(fn{i}) = repmat(DS.(fn{i}),MaskSize,1);
				SZ = size(DS.(fn{i}),1);
			end

			if SZ ~= MaskSize
				disp(DS.experiment_idx(i))
				error('Something wrong with this data')
			end
		end

	end % constructor


	function out = horzcat(varargin)

		for i = 1:length(varargin)
			assert(isa(varargin{i},'embedding.DataStore'),'Cannot concat embedding.DataStore with other data types')
		end


		allprops = {};
		for i = 1:length(varargin)
			allprops = unique([allprops; properties(varargin{i})]);
		end

		for i = 1:length(varargin)
			for j = 1:length(allprops)
				if isprop(varargin{i},allprops{j})
					continue
				end

				varargin{i}.addprop(allprops{j});
				keyboard

			end

		end

		keyboard

	end


	function out = vertcart(varargin)
		keyboard
	end


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