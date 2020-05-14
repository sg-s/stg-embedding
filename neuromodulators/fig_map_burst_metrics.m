% in this figure, we label sub-clusters by burst metrics


if ~exist('alldata','var')
    init()
end

clearvars -except data alldata p

R = double(alldata.R);

cats = categories(alldata.idx);
colors = display.colorscheme(cats);



figure('outerposition',[300 108 1301 1301],'PaperUnits','points','PaperSize',[1301 1301]); hold on

axis off
axis square

figlib.pretty('LineWidth',1)

sub_idx = embedding.watersegment(alldata);

% find burstmetrics by subcluster
PD_dc = NaN*(1:max(sub_idx));
PD_period = NaN*(1:max(sub_idx));
LP_dc = NaN*(1:max(sub_idx));
LP_delay = NaN*(1:max(sub_idx));

PD_dc_std = NaN*(1:max(sub_idx));
PD_period_std = NaN*(1:max(sub_idx));
LP_dc_std = NaN*(1:max(sub_idx));
LP_delay_std = NaN*(1:max(sub_idx));

for i = 1:max(sub_idx)
	PD = alldata.PD(sub_idx==i,:);
	this_PD_dc = NaN(size(PD,1),1);
	this_PD_period = NaN(size(PD,1),1);
	for j = 1:length(this_PD_dc)
		temp = xtools.spiketimes2BurstMetrics(PD(j,:),'MinNSpikesPerBurst',1);
		this_PD_dc(j) = temp.duty_cycle_mean;
		this_PD_period(j) = temp.burst_period_mean;
	end
	PD_dc(i) = nanmean(this_PD_dc);
	PD_period(i) = nanmean(this_PD_period);
	PD_dc_std(i) = nanstd(this_PD_dc);
	PD_period_std(i) = nanstd(this_PD_period);

	LP = alldata.LP(sub_idx==i,:);
	this_LP_dc = NaN(size(LP,1),1);
	for j = 1:length(this_LP_dc)
		temp = xtools.spiketimes2BurstMetrics(LP(j,:),'MinNSpikesPerBurst',1);
		this_LP_dc(j) = temp.duty_cycle_mean;
	end
	LP_dc(i) = nanmean(this_PD_dc);
	LP_dc_std(i) = nanstd(this_PD_dc);

	% phase
	temp = alldata.PD_LP(sub_idx==i,:);
	LP_delay(i) = nanmean(temp(:))/PD_period(i);
	LP_delay_std(i) = nanstd(temp(:))/PD_period(i);
end


fh = display.plotSubClusters(gca,alldata,.1,sub_idx);


radius = @(x) 1 + 1*(x - min(PD_period))/(max(PD_period) - min(PD_period));

E = (LP_dc_std./LP_dc + PD_dc_std./PD_dc);
E2 = LP_delay./LP_delay_std;
for i = 1:max(sub_idx)
	mx = mean(R(sub_idx==i,1));
	my = mean(R(sub_idx==i,2));
	if ~isnan(PD_dc(i)) && ~isnan(LP_dc(i)) && ~isnan(LP_delay(i)) && E(i) < 1 && E2(i) < 5
		display.activityRing([mx my],PD_dc(i),LP_dc(i),LP_delay(i),radius(PD_period(i)))

	end
end

return



clearvars -except data alldata p