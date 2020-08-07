classdef DataStore

properties



	mask logical = true % should we ignore these sections?
	unusable double = 0 % is this unusable?

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



	function data = purge(data,rm_this)

		assert(isscalar(data),'Expected data to be scalar')
		assert(isvector(rm_this),'Expected rm_this to be a vector')
		assert(islogical(rm_this),'Expected rm_this to be logical')
		rm_this = rm_this(:);
		assert(length(data.mask) == length(rm_this),'Expected rm_this to be the same length as data.mask')

		props = properties(data);
		for i = 1:length(props)
			if isvector(data.(props{i}))
				data.(props{i})(rm_this) = [];
			else
				data.(props{i})(:,rm_this) = [];
			end
		end

	end % purge



end % methods



methods (Static)

	function D = defaults()

		DS = embedding.DataStore;
		props = properties(DS);
		props = setdiff(props,'time_offset');
		props = setdiff(props,'mask');

		D = struct;
		for i = 1:length(props)
			if size(DS.(props{i}),1)>1
				continue
			end
			if iscategorical(DS.(props{i}))
				continue
			end
			D.(props{i}) = DS.(props{i});
		end

	end % defaults


end % static methods


end % classdef