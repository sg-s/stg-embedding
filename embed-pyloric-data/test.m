% in this script, we dick around with different cost functions, etc.


% embed with default settings
load('mdata')


% we can safely remove an offset
offsets = (nanmin(vertcat((nanmin(mdata.LP)),nanmin(mdata.PD))));
for i = 1:970
	mdata.PD(:,i) = mdata.PD(:,i) - offsets(i);
	mdata.LP(:,i) = mdata.LP(:,i) - offsets(i);
end


data = thoth.computeISIs(mdata, fieldnames(mdata));


% now measure distances -- locally 
D = zeros(970,970,4);
fn = {'PD_PD','LP_LP','PD_LP','LP_PD'};



% penalize low firing states by adding a phantom spike at the end
% when the last spike occurs less than 2 seconds from the end
for i = 1:970
	if nanmax(data.PD_PD(:,i)) < 18
		data.PD_PD(find(isnan(data.PD_PD),1,'first'),i) = 2;
	end

	if nanmax(data.LP(:,i)) < 18
		data.LP_LP(find(isnan(data.LP_LP),1,'first'),i) = 2;
	end
end



for i = 1:length(fn)
	D(:,:,i) = neurolib.ISIDistance(data.(fn{i}));
end

%% exxagerate the delays
D(:,:,3:4) = D(:,:,3:4);


eD = sum(D,3);
eD = eD + eD';







t = TSNE; 
t.perplexity = 60;
t.distance_matrix = eD;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;





plot_data = data;
explore



return

% plot the data and colour by things

% estimate burst periods of all
for i = 1:970
	LPmetrics(i) = xtools.spiketimes2BurstMetrics(data.LP(:,i));
	PDmetrics(i) = xtools.spiketimes2BurstMetrics(data.PD(:,i));
end



figure('outerposition',[300 300 901 999],'PaperUnits','points','PaperSize',[901 999]); hold on

clear ax
for i = 1:4
	ax(i) = subplot(2,2,i); hold on
	plot(R(:,1),R(:,2),'.','MarkerSize',36,'Color',[.8 .8 .8])
end

C = [LPmetrics.burst_period_std];
C(C > 2) = NaN;
scatter(ax(1),R(:,1),R(:,2),34,C,'filled')
title(ax(1),'LP burst period')


C = [PDmetrics.burst_period_std];
C(C > 2) = NaN;
scatter(ax(2),R(:,1),R(:,2),34,C,'filled')
title(ax(2),'PD burst period')

C = [LPmetrics.duty_cycle_std];
C(C > 2) = NaN;
scatter(ax(3),R(:,1),R(:,2),34,C,'filled')
title(ax(3),'LP duty cycle')
colorbar

C = [PDmetrics.duty_cycle_std];
C(C > 2) = NaN;
scatter(ax(4),R(:,1),R(:,2),34,C,'filled')
title(ax(4),'PD duty cycle')
colorbar

