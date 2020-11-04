

%% in this figure we look at metrics to see if we can recapitulate old data
% with neuromodulators (a useful sanity check)


figure('outerposition',[300 300 1500 901],'PaperUnits','points','PaperSize',[1500 901]); hold on

clear ax

modnames = {'proctolin','oxotremorine','serotonin'};

for i = 1:2
	ax(i) = subplot(1,2,i); hold on


	% find all preps where this mod is used
	preps = unique(moddata.experiment_idx(moddata.(modnames{i}) > 0));
	this = ismember(moddata.experiment_idx,preps) & moddata.experimenter == 'haddad';
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