%%
% In this script we make some synthetic data and embed this to understand how the emedding works


data = synthetic.makeData;


figure('outerposition',[300 300 1200 1111],'PaperUnits','points','PaperSize',[1200 1111]); hold on


cats = unique(data.experiment_idx);

for i = 1:9
	subplot(3,3,i); hold on

	plot_this = find(data.experiment_idx == cats(i));


	yoffset = 0;
	for idx = 3:5
		neurolib.raster(data.PD(:,plot_this(idx)),data.LP(:,plot_this(idx)),'split_rows',true,'deltat',1,'center',false,'yoffset',yoffset); 
		yoffset = yoffset + 3;
	end

	set(gca,'XLim',[0 5],'YLim',[0 8],'YTick',[])
	title(char(cats(i)))
	axis off

end

figlib.pretty



% convert to ISIs
data = thoth.computeISIs(data,{'PD','LP'});



%%
% In the following figure, I plot all the ISIs for all the states so we can get a sense of how the ISI-based distance functions will work


for figidx = 1:3

	figure('outerposition',[300 300 1200 1111],'PaperUnits','points','PaperSize',[1200 1111]); hold on


	things_to_show = {'PD_PD','LP_LP','PD_LP','LP_PD'};

	for i = 1:3

		this_cat = cats((figidx-1)*3+i);


		idx = i;



		subplot(5,3,idx); hold on

		% show the spike times

		plot_this = find(data.experiment_idx == this_cat);
		neurolib.raster(data.PD(:,plot_this(idx)),data.LP(:,plot_this(idx)),'split_rows',true,'deltat',1,'center',false); 
		title(char(this_cat))
		set(gca,'XLim',[0 5],'YLim',[0 2])



		% show PD isis
		for j = 1:4
			idx = idx + 3;
			subplot(5,3,idx); hold on

			isis = data.(things_to_show{j})(:,plot_this(1:10:end));
			time = repmat(1:size(isis,2),1e3,1);
			time = time(:);
			isis = isis(:);

			plot(time,isis,'k.')
			set(gca,'YScale','log','YLim',[1e-2 1e1])
			if i == 1
				ylabel(things_to_show{j},'interpreter','none')
			end
		end

	end

	figlib.pretty

end