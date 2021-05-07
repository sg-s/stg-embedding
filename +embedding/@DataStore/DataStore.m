% embedding.DataStore defines a class
% that we use to store our data. It contains spiketimes
% in PD and LP, ISIs in the appropriately named variables
% and a whole bunch of metadata vectors 
%
% The goal is to create DataStores from data, and then never touch
% them or modify them

classdef DataStore < Hashable



properties

	% stores the manually assigned labels
	idx categorical = categorical(NaN)


	% these props may be changed for some temporary analysis
	LP_channel categorical  = categorical(NaN)
	PD_channel  categorical = categorical(NaN)

end

% these properties may be modified, but only by 
% methods of DataStore
properties (SetAccess = private)


	% ISIs will be computed by a method
	% called computedISIs. Hence they can't be 
	% immutable
	LP_LP double = NaN(1,1e3)
	LP_PD double = NaN(1,1e3)
	PD_LP double = NaN(1,1e3)
	PD_PD double = NaN(1,1e3)


	% time_offset is going to be fiddled with
	% to account for breaks in files 
	time_offset double = 0 


end


properties (SetAccess = immutable)

	% spikes
	LP  double = NaN(1,1e3)
	PD double = NaN(1,1e3)

	% metadata
	mask logical = true % should we ignore these sections?
	unusable double = 0 % is this unusable?

	
	baseline double = 1
	decentralized logical = false

	temperature double = 11

	

	experiment_idx categorical = categorical(NaN)
	experimenter categorical = categorical(NaN)



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



	function DS = DataStore(data, skip_checks)

		if nargin == 0
			return
		end

		if nargin < 2
			skip_checks = false;
		end

		assert(isstruct(data),'DataStore should be constructed using a struct')



		% clean up the channel names a little		
	    data.LP_channel(data.LP_channel == 'LP2') = 'LP';
	    data.PD_channel(data.PD_channel == 'PD2') = 'PD';
	    data.PD_channel(data.PD_channel == 'pdn2') = 'pdn';
	    data.PD_channel(data.PD_channel == 'lvn2') = 'lvn';





		fn = fieldnames(data);
		for i = 1:length(fn)
			DS.(fn{i}) = data.(fn{i});
		end


		if skip_checks
			return
		end

		% make sure spikes are sorted
		DS.PD = sort(DS.PD,2);
		DS.LP = sort(DS.LP,2);


		% size the ISIs correctly
		fn = {'LP_LP','LP_PD','PD_LP','PD_PD'};
		for i = 1:length(fn)
			if isempty(DS.(fn{i}))
				DS.(fn{i}) = DS.PD*NaN;
			end
		end


		% delete spikes that are closer than 3ms to other spikes
        min_isi = .003;
        for j = 1:length(DS.mask)
            spikes = DS.LP(j,:);
            delete_these = find(diff(spikes)<min_isi);
            if ~isempty(delete_these)
                DS.LP(j,delete_these) = NaN;
                DS.LP(j,:) = sort(DS.LP(j,:));
            end

            spikes = DS.PD(j,:);
            delete_these = find(diff(spikes)<min_isi);
            if ~isempty(delete_these)
                DS.PD(j,delete_these) = NaN;
                DS.PD(j,:) = sort(DS.PD(j,:));
            end
        end



		

		% make sure everything has the same size
		fn = properties(DS);
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




end % methods



methods (Static)

	function D = defaults()

		DS = embedding.DataStore;
		props = properties(DS);
		props = setdiff(props,'time_offset');
		props = setdiff(props,'idx');
		props = setdiff(props,'mask');
		props = setdiff(props,{'LP','PD','PD_PD','LP_LP','LP_PD','PD_LP'});

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