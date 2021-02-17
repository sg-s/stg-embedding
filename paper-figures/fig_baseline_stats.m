% show baseline stats by prep for all data

init
close all


% drawing constants
lp_color = color.aqua('red');
pd_color = color.aqua('indigo');


figure('outerposition',[300 300 1500 901],'PaperUnits','points','PaperSize',[1500 901]); hold on

clear ax




% average things by prep
p = struct;
CV = struct; % stores the CVs of each metric
SD = struct; % stores standard deviation of each metric
fn = fieldnames(basemetrics);
fn = setdiff(fn,{'PD_nspikes','LP_nspikes','PD_delay_on','PD_phase_on','LP_burst_period'});
sort_mean = NaN;
across_animal_MS = NaN(length(fn),1);
within_animal_MS = NaN(length(fn),1);
p_anova = NaN(length(fn),1);

N = 2:30;
Nrep = 2;
p_N = struct;


for i = 1:length(fn)
	disp(fn{i})

	this = basemetrics.(fn{i});
	groups = basedata.experiment_idx;
	rm_this = basedata.idx ~= 'normal';
	this(rm_this) = [];
	groups(rm_this) = [];
	[M,S] = analysis.averageBy(this,groups);
	p.(fn{i}) = M;
	CV.(fn{i}) = S./M;
	SD.(fn{i}) = S;
	within_prep(i) = nanmean(CV.(fn{i}));
	sort_mean(i) = nanmean(M);

	% anova
	[~,tbl] = anova1(this,groups,'off');
	across_animal_MS(i) = tbl{2,4};
	within_animal_MS(i) = tbl{3,4};
	p_anova(i) = tbl{2,6};


	unique_groups = unique(groups);

	% randomly choose N crabs and compute the p-value from the anova
	p_N.(fn{i}) = zeros(length(N),Nrep);
	for j = 1:length(N)
		n = N(j);
		for k = 1:Nrep
			g = datasample(unique_groups,n,'Replace',false);
			use_this = ismember(groups,g);
			p_N.(fn{i})(j,k) = anova1(this(use_this), groups(use_this),'off');
		end
	end
	
end

return

N_sample_reqd = NaN(length(fn),1);
for i = 1:length(N_sample_reqd)
	N_sample_reqd(i) = sampsizepwr('t',[mean(CV.(fn{i})) std(CV.(fn{i}))],statlib.cv(p.(fn{i})),.99,[],'Tail','right');
end


% temp diagnostic plots
% figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
% m = length(fieldnames(p_N));
% for i = 1:m
% 	figlib.autoPlot(m,i); hold on
% 	plot(N,mean(p_N.(fn{i}),2))
% 	set(gca,'YScale','log')
% 	ylabel('p')
% 	xlabel('N')
% 	title(fn{i},'interpreter','none')
% 	plotlib.horzline(gca,.01,'k--')
% end
% figlib.pretty()

F = across_animal_MS./within_animal_MS;

table(fn,across_animal_MS,within_animal_MS,F,N_sample_reqd)


% reorder metrics by within_prep variability
[~, sidx] = sort(sort_mean);
within_prep = within_prep(sidx);
fn = fn(sidx);



% shuffle the data and recalculate
[p_shuffled, CV_shuffled] = analysis.bootstrapMetrics(basemetrics, basedata.experiment_idx, fn);

across_prep_shuffled = NaN*CV_shuffled;
for i = 1:length(fn)
	for j = 1:size(CV_shuffled,2)
		across_prep_shuffled(i,j) = statlib.cv(p_shuffled(j).(fn{i}));
	end
end

% show raincloud plots of all metrics we measure
ax.means = subplot(1,4,1); hold on
L = {};
for i = 1:length(fn)
	if any(strfind(fn{i},'PD'))
		C = pd_color;
	else
		C = lp_color;
	end
	plotlib.raincloud(p.(fn{i}),'YOffset',2*i,'Height',.5,'Color',C);
	L{i} = strrep(fn{i},'_',' ');

	if any(strfind(L{i},'duty')) | any(strfind(L{i},'phase'))
	else
		L{i} = [L{i} ' (s)'];
	end
end
set(ax.means,'YTick',[2:2:2*length(fn)],'YTickLabel',L)
ax.means.YLim = [0 2*i+2];
ax.means.XLim = [0 2];
xlabel(ax.means,'Mean','FontWeight','normal')




% another raincloud to compare variability between different measures
ax.variability = subplot(1,4,2); hold on

for i = 1:length(fn)
	if any(strfind(fn{i},'PD'))
		C = pd_color;
	else
		C = lp_color;
	end

	plot_this = CV.(fn{i});
	plot_this = log10(plot_this);
	plot_this(isinf(plot_this)) = [];
	plot_this(isnan(plot_this)) = [];

	plotlib.raincloud(plot_this,'YOffset',2*i,'Height',.5,'Color',C);



end
set(ax.variability,'YTick',[2:2:2*length(fn)],'YTickLabel',{})
ax.variability.YLim = [0 2*i+2];



% convert to log ticks
xlabel(ax.variability,'CV','FontWeight','normal')




% compare within prep and between-prep variability 
ax.var_vs_var = subplot(1,4,3); hold on
ax.excess_var = subplot(1,4,4); hold on
xlabel({'Across animal - ','within animal variability'})
clear ph
for i = 1:length(fn)
	if any(strfind(fn{i},'PD'))
		C = pd_color;
	else
		C = lp_color;
	end

	
	across_prep = statlib.cv(p.(fn{i}));

	h = plot(ax.var_vs_var,[within_prep(i) across_prep], [2*i 2*i],'LineWidth',3,'Color','k');

	plot(ax.var_vs_var,within_prep(i),2*i,'o','MarkerSize',10,'Color',C,'MarkerFaceColor',C)
	plot(ax.var_vs_var,across_prep,2*i,'^','MarkerSize',10,'Color',C,'MarkerFaceColor',C)

	


	% plot excess variance in shuffled data
	plot_this = across_prep_shuffled(i,:) - CV_shuffled(i,:);
	axes(ax.excess_var)
	plotlib.raincloud(plot_this,'YOffset',2*i,'Height',.5,'Color',[.5 .5 .5]);

	% plot excess variance
	plot(ax.excess_var,across_prep - within_prep(i), 2*i,'o','MarkerSize',10,'MarkerFaceColor',C,'Color',C);

	disp(fn{i})
	disp(mean(plot_this > across_prep - within_prep(i)))

end

% fake a plot for the legend
ph(1) = plot(ax.var_vs_var,NaN,NaN,'ko','MarkerSize',10,'MarkerFaceColor','k');
ph(2) = plot(ax.var_vs_var,NaN,NaN,'k^','MarkerSize',10,'MarkerFaceColor','k');

ax.var_vs_var.YLim = [0 2*i+2];
ax.excess_var.YLim = [0 2*i+2];
set(ax.var_vs_var,'YTick',[2:2:2*length(fn)],'YTickLabel',{})
set(ax.excess_var,'YTick',[2:2:2*length(fn)],'YTickLabel',{})
xlabel(ax.var_vs_var,'Variability')
ax.var_vs_var.XLim = [0 1];
l = legend(ph,{'<CV>','CV(mean)'});





figlib.pretty('FontSize',14)

ax.variability.XTickLabel = axlib.makeLogTickLabels(10.^(ax.variability.XTick));


ax.excess_var.YAxisLocation = 'right';
ax.variability.YColor = 'w';
ax.var_vs_var.YColor = 'w';
ax.excess_var.XLim = [-.25 1];

plotlib.vertline(ax.excess_var,0,'k:');

% ax.excess_var.YGrid = 'on';
% ax.means.YGrid = 'on';
% ax.variability.YGrid = 'on';
% ax.var_vs_var.YGrid = 'on';


figlib.tight
drawnow

figlib.label('XOffset',-.01,'YOffset',-0.04)


figlib.saveall('Location',display.saveHere)


% another init to clear away all extra variables
init()


