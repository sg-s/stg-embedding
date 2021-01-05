

%% in this figure we look at metrics to see if we can recapitulate old data
% with neuromodulators (a useful sanity check)





% proctolin

% find all preps where this mod is used
preps = unique(moddata.experiment_idx(moddata.proctolin > 0));


before = struct;
after = struct;
dec = struct;
metrics = {'LP_nspikes','PD_burst_period'};

for i = 1:length(metrics)
	before.(metrics{i}) = NaN(length(preps),1);
	after.(metrics{i}) = NaN(length(preps),1);
	dec.(metrics{i}) = NaN(length(preps),1);

end



for i = 1:length(preps)
	prep = preps(i);

	for j = 1:length(metrics)
		before.(metrics{j})(i) = nanmean(modmetrics.(metrics{j})(moddata.experiment_idx == prep & moddata.decentralized == 0));
		after.(metrics{j})(i) = nanmean(modmetrics.(metrics{j})(moddata.experiment_idx == prep & moddata.proctolin > 0));
		dec.(metrics{j})(i) = nanmean(modmetrics.(metrics{j})(moddata.experiment_idx == prep & moddata.proctolin == 0 & moddata.decentralized));
	end

	
end


% outliers
after.LP_nspikes(after.LP_nspikes>50) = NaN;

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(2,3,1); hold on
plot(before.LP_nspikes,after.LP_nspikes,'o')
plotlib.drawDiag(gca,'k--')

subplot(2,3,4); hold on
plot(dec.LP_nspikes,after.LP_nspikes,'o')
plotlib.drawDiag(gca,'k--')

subplot(2,3,2); hold on
plot(before.PD_burst_period,after.PD_burst_period,'o')
plotlib.drawDiag(gca,'k--')

subplot(2,3,5); hold on
plot(dec.PD_burst_period,after.PD_burst_period,'o')
plotlib.drawDiag(gca,'k--')


return



modnames = {'proctolin','oxotremorine','serotonin'};

for i = 1:2
	ax(i) = subplot(1,2,i); hold on


	
	this = ismember(moddata.experiment_idx,preps) %& moddata.experimenter == 'haddad';
preps = moddata.slice(this);



	% split into animal by animal
	preps = preps.split();

	T_baseline = NaN(length(preps),1);
	T_mod = NaN(length(preps),1);

	for j = 1:length(preps)
		m = structlib.scalarify(preps(j).ISI2BurstMetrics);
		T_baseline(j) = nanmean(m.PD_burst_period(preps(j).decentralized == false));
		T_mod(j) = nanmean(m.PD_burst_period(preps(j).(modnames{i}) > 0));
	end


	plot(T_baseline,T_mod,'o')
	xlabel('Baseline burst period (s)')
	ylabel('Modulator burst period (s)')

	title(modnames{i})

	plotlib.drawDiag;
	

end


figlib.pretty()