%%
% In this document I look at how transitions are affected by
% environmental perturbations


close all
init()

colors = display.colorscheme(decdata.idx);
cats = categories(alldata.idx);

things_to_measure = {'PD_burst_period','LP_burst_period'};
t_before = 10;

if ~exist('plot_here','var')
	figure('outerposition',[300 300 1444 800],'PaperUnits','points','PaperSize',[1444 800]); hold on
	plot_here = subplot(1,2,1); hold on
	plot_here(2) = subplot(1,2,2); hold on

end

T = (0:-1:-t_before+1)*20;


only_when = decdata.decentralized;

[CV, CV0] = analysis.measureRegularCVBeforeTransitions(decdata,allmetrics,only_when,'things_to_measure',things_to_measure,'t_before',t_before);


% remove outliers
for j = 1:length(things_to_measure)
	thing = things_to_measure{j};
	[~,TF] = rmoutliers(CV.(thing)(:,1));
	CV.(thing)(TF,:) = NaN;


	% compute p using paired permutation test
	p = zeros(size(CV.(thing),2),1);
	for k = 1:length(p)
		p(k) = statlib.pairedPermutationTest(CV.(thing)(:,k),CV0.(thing));
		if nanmean(CV.(thing)(:,k)) < nanmean(CV0.(thing))
			p(k) = NaN;
		end
	end

	axes(plot_here(j))

	if any(strfind(thing,'PD'))
		Color = colors.PD;
	else
		Color = colors.LP;
	end

	plotlib.barWithErrorStar(T,nanmean(CV.(thing)),nanstd(CV.(thing)),p<.05/length(p),'Color',Color,'offset',.2);

	% does variability increase with time before transition? 
	[rho,p] = statlib.correlation(1:t_before,nanmean(CV.(thing)),'Type','spearman');

	th = text(-190,.1,['\rho=' mat2str(-rho,2) ', p=' mat2str(p,2)]);
	th.FontSize = 20;

end





