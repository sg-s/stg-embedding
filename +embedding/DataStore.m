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


	function snakePlot(data, ax)

		if nargin == 1
			figure('outerposition',[300 300 400 700],'PaperUnits','points','PaperSize',[400 700]); hold on
			ax = gca;
		end

		assert(length(ax)==1,'Expected axes handle to be one element long')
		assert(isa(ax,'matlab.graphics.axis.Axes'),'Axes handle is not valid')
		assert(length(find(data.time_offset == 0))==1,'Data has a break')


		xbins = logspace(-2,1,101);
		PD_PD = zeros(100,length(data.mask));
		for i = 1:length(data.mask)
			PD_PD(:,i) = histcounts(data.PD_PD(:,i),'BinEdges',xbins);
		end

		[~,h] = contour(PD_PD');
		
		PD_PD = (imgaussfilt(PD_PD',1));

		keyboard

		PD = sort(data.PD(:));
		LP = sort(data.LP(:));

		isiPD = [NaN; diff(PD)];
		isiLP = [NaN; diff(LP)];

		isiPD(isiPD>10) = NaN;
		isiLP(isiLP>10) = NaN;


		plot(ax,isiPD,PD,'k.')
		plot(ax,isiLP*100,LP,'r.')

		ax.XScale = 'log';
		%ax(1).XLim = [1e-2 10];


	end % snakePlot


end % methods




end % classdef