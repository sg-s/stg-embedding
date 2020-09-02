% show baseline stats by prep for all data

init
close all


% drawing constants
lp_color = color.aqua('red');
pd_color = color.aqua('indigo');


figure('outerposition',[300 300 1500 901],'PaperUnits','points','PaperSize',[1500 901]); hold on

clear ax
ax.states = subplot(3,1,1); hold on
[h,P] = display.plotStateDistributionByPrep(basedata.idx, basedata.experiment_idx);

[~,sort_order]= sort(P(:,1),'descend');
delete(h)
P = P(sort_order,:);
h = bar(P,'stacked','LineStyle','-','BarWidth',1);
xlabel('Preparation')
ylabel('Fraction of time in state')
ax.states.XLim(1) = 1;
ax.states.YLim = [0 1];

% get the colors right
cats = categories(basedata.idx);
colors = display.colorscheme(cats);

for i = 1:length(h)
	h(i).FaceColor = colors(cats{i});
end



% find the duration of data for each prep
all_preps = unique(basedata.experiment_idx);
T = histcounts(basedata.experiment_idx, all_preps);
T = T(sort_order);



% average things by prep
p = struct;
CV = struct; % stores the CVs of each metric
fn = fieldnames(basemetrics);
for i = 1:length(fn)
	[M,S] = analysis.averageBy(basemetrics.(fn{i}),basedata.experiment_idx);
	p.([fn{i}]) = M;
	CV.([fn{i}]) = S./M;
end



% show raincloud plots of all metrics we measure
ax.means = subplot(3,4,[5 9]); hold on
fn = fieldnames(p);
fn = setdiff(fn,{'PD_nspikes','LP_nspikes','PD_delay_on','PD_phase_on','LP_burst_period'});
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
title(ax.means,'Mean of...','FontWeight','normal')




% another raincloud to compare variability between different measures
ax.variability = subplot(3,4,[6 10]); hold on

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
ax.variability.XTickLabel = axlib.makeLogTickLabels(10.^(ax.variability.XTick));
title(ax.variability,'CV of...','FontWeight','normal')




% compare within prep and between-prep variability 
ax.var_vs_var = subplot(3,4,[7 11]); hold on

clear ph
for i = 1:length(fn)
	if any(strfind(fn{i},'PD'))
		C = pd_color;
	else
		C = lp_color;
	end

	within_prep = nanmean(CV.(fn{i}));
	across_prep = nanmean(CV.(fn{i})./p.(fn{i}));

	h = plot([within_prep across_prep], [2*i 2*i],'LineWidth',3,'Color','k');

	plot(within_prep,2*i,'o','MarkerSize',10,'Color',C,'MarkerFaceColor',C)
	plot(across_prep,2*i,'^','MarkerSize',10,'Color',C,'MarkerFaceColor',C)

	

	if within_prep > across_prep
		h.Color = 'g';
	end


	% fake a plot for the legend
	ph(1) = plot(NaN,NaN,'ko','MarkerSize',10,'MarkerFaceColor','k');
	ph(2) = plot(NaN,NaN,'k^','MarkerSize',10,'MarkerFaceColor','k');

end
ax.var_vs_var.YLim = [0 2*i+2];
set(ax.var_vs_var,'YTick',[2:2:2*length(fn)],'YTickLabel',{})
xlabel(ax.var_vs_var,'Variability')
ax.var_vs_var.XLim = [0 1];
l = legend(ph,{'<CV>','CV(mean)'});
l.Position = [.58 .4 .06 .04];

% compare latencies and phases and show phase constancy
Show1 = {'PD_durations','LP_delay_on','LP_delay_off'};
Show2 = {'PD_duty_cycle','LP_phase_on','LP_phase_off'};
C = lines;
X = p.PD_burst_period;

ax.delays = subplot(3,4,8); hold on
clear h
for i = 1:length(Show1)
	Y = p.(Show1{i});
	plot(X,Y,'.','Color',C(i,:));
	this = ~isnan(X) & ~isnan (Y);
	ff = fit(X(this),Y(this),'poly1');
	plot([0 2],ff([0 2]),'Color',C(i,:))

	% fake plot
	h(i) = plot(NaN,NaN,'.','Color',C(i,:),'MarkerSize',34);

end
lh = legend(h,{'PD off','LP on','LP off'},'Location','northwest');


% phases vs periods to show constancy?

ax.phases = subplot(3,4,12); hold on

for i = 1:length(Show2)
	Y = p.(Show2{i});
	plot(X,Y,'.','Color',C(i,:))
	this = ~isnan(X) & ~isnan (Y);
	ff = fit(X(this),Y(this),'poly1');
	plot([0 2],ff([0 2]),'Color',C(i,:))
end


figlib.pretty('FontSize',14)





xlabel(ax.delays,'Burst period (s)')
xlabel(ax.phases,'Burst period (s)')
ax.phases.YLim = [0 1];
ax.delays.YLim = [0 1.3];
ylabel(ax.delays,'Delays (s)')
ylabel(ax.phases,'Phase')
ax.delays.XAxisLocation = 'top';
ax.var_vs_var.YAxisLocation = 'right';
ax.variability.YColor = 'w';


% minor positioning fixes
ax.states.Position = [.13 .75 .75 .18];
ax.variability.Position(1) = .31;
ax.var_vs_var.Position(1) = .5;

ax.delays.Position(4) = .2;
ax.phases.Position(4) = .2;
ax.delays.Position(2) = .35;



figlib.saveall('Location',display.saveHere)


% another init to clear away all extra variables
init()


