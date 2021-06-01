%%
% In this document I look at how transitions are affected by
% environmental perturbations


close all
init()

colors = display.colorscheme(alldata.idx);

conditions = {alldata.temperature >= 25 & (alldata.decentralized == false), alldata.pH < 6.5, alldata.Potassium > 1};

things_to_measure = {'PD_burst_period','LP_burst_period'};
t_before = 10;

figure('outerposition',[300 300 1444 1100],'PaperUnits','points','PaperSize',[1444 1100]); hold on
n = 1;
for i = 1:length(things_to_measure)
	for j = 1:length(conditions)
		ax(j,i) = subplot(length(things_to_measure),length(conditions),n); hold on
		set(gca,'YLim',[0 .15])
		n = n+1;
	end
end

figlib.pretty

title(ax(1,1),['T > 25' char(176)  'C'])
title(ax(2,1),'pH < 6.5')
title(ax(3,1),'2.5x [K^+]')

ylabel(ax(1,1),'CV (PD burst period)')
ylabel(ax(1,2),'CV (LP burst period)')

xlabel(ax(1,2),'Time before transition (s)')
xlabel(ax(2,2),'Time before transition (s)')
xlabel(ax(3,2),'Time before transition (s)')

T = (0:-1:-t_before+1)*20;

for i = 1:length(conditions)
	only_when = conditions{i};

	[CV, CV0] = analysis.measureRegularCVBeforeTransitions(alldata,allmetrics,only_when);


	% remove outliers
	for j = 1:length(things_to_measure)
		thing = things_to_measure{j};
		[~,TF]=rmoutliers(CV.(thing)(:,1));
		CV.(thing)(TF,:) = NaN;


		% % compute p using pairedpermutation test
		p = zeros(size(CV.(thing),2),1);
		for k = 1:length(p)
			p(k) = statlib.pairedPermutationTest(CV.(thing)(:,k),CV0.(thing));
			if nanmean(CV.(thing)(:,k)) < nanmean(CV0.(thing))
				p(k) = NaN;
			end
		end

		axes(ax(i,j))

		if any(strfind(thing,'PD'))
			Color = colors.PD;
		else
			Color = colors.LP;
		end

		plotlib.barWithErrorStar(T,nanmean(CV.(thing)),nanstd(CV.(thing)),p<.05/length(p),'Color',Color,'offset',.2);

	end

end



