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


	function DS = combine(data)
		% combines a vector of DataStore objects into a single scalar object by concatenating all properties 
		DS = embedding.DataStore;
		props = properties(DS);
		for i = 1:length(props)
			if isscalar(DS.(props{i}))
				DS.(props{i}) = vertcat(data.(props{i}));
			else
				DS.(props{i}) = horzcat(data.(props{i}));
			end
		end
	end % combine


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

	function snakePlot(data, ax)

		if nargin == 1
			figure('outerposition',[300 300 400 700],'PaperUnits','points','PaperSize',[400 700]); hold on
			ax = gca;
			
		end

		r = rectangle(ax,'Position',[.1 .1 1 1]);

		assert(length(ax)==1,'Expected axes handle to be one element long')
		assert(isa(ax,'matlab.graphics.axis.Axes'),'Axes handle is not valid')

		% purge all discontinuous data

		last_reset = find(data.time_offset == 0,1,'last');
		if last_reset ~= 1
			rm_this = logical(data.mask*0);
			rm_this(1:last_reset-1) = true;
			data = data.purge(rm_this);
		end

		assert(length(find(data.time_offset == 0))==1,'Data has a break')


		PD = sort(data.PD(:));
		LP = sort(data.LP(:));

		isiPD = [NaN; diff(PD)];
		isiLP = [NaN; diff(LP)];

		isiPD(isiPD>10) = NaN;
		isiLP(isiLP>10) = NaN;



		isiLP(isiLP<1e-2) = NaN;


		% mark when it is decentralized
		temp = [data.PD(:,find(data.decentralized,1,'first'):end); data.LP(:,find(data.decentralized,1,'first'):end)];
		

		PD(PD>nanmin(temp(:))+1000) = NaN;
		LP(LP>nanmin(temp(:))+1000) = NaN;

		plot(ax,isiPD,PD,'.','Color',color.onehalf('blue'),'MarkerSize',1)
		plot(ax,isiLP*100,LP,'.','Color',color.onehalf('orange'),'MarkerSize',1)



		ax.XScale = 'log';
		

		try
			r.Position = [.01 nanmin(temp(:)) 300 1000];
			ax.YLim = [nanmin(data.PD(:)) nanmax(data.PD(:))];
		catch
		end
		r.FaceColor = [.95 .95 .95];
		r.LineStyle = 'none';

		
		ax.YDir = 'reverse';
		ax.YColor = 'w';
		ax.YTick = [];

		ax.YLim = [nanmin(temp(:)) - 300 nanmin(temp(:)) + 1050];
		ax.XLim = [.01 200];



	end % snakePlot


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