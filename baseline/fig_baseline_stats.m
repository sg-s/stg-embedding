% show baseline stats by prep for all data

close all

lp_color = color.aqua('red');
pd_color = color.aqua('indigo');

if ~exist('burst_metrics','var')
	normaldata = alldata.purge(alldata.idx ~='normal');
	burst_metrics = normaldata.ISI2BurstMetrics;
	burst_metrics = structlib.scalarify(burst_metrics);
end

figure('outerposition',[300 300 1500 901],'PaperUnits','points','PaperSize',[1500 901]); hold on

clear ax
ax.states = subplot(3,1,1); hold on
[h,P] = display.plotStateDistributionByPrep(alldata.idx, alldata.experiment_idx,true(length(alldata.mask),1));

[~,sort_order]= sort(P(:,1),'descend');
delete(h)
P = P(sort_order,:);
h = bar(P,'stacked','LineStyle','-','BarWidth',1);
xlabel('Preparation')
ylabel('Fraction of time in state')
ax.states.XLim(1) = 1;
ax.states.YLim = [0 1];

% get the colors right
cats = categories(alldata.idx);
colors = display.colorscheme(cats);

for i = 1:length(h)
	h(i).FaceColor = colors(cats{i});
end



% average things by prep
p = struct;
fn = fieldnames(burst_metrics);
for i = 1:length(fn)
	[M,S] = analysis.averageBy(burst_metrics.(fn{i}),normaldata.experiment_idx);
	p.([fn{i}]) = M;
end



% show raincloud plots of all metrics we measure
ax.raincloud = subplot(3,4,[5 9]); hold on
fn = fieldnames(p);
fn = setdiff(fn,{'PD_nspikes','LP_nspikes','PD_delay_on'});
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
set(ax.raincloud,'YTick',[2:2:2*length(fn)],'YTickLabel',L)
ax.raincloud.YLim = [0 2*i+2];
ax.raincloud.XLim = [0 2];





% compare latencies and phases and show phase constancy
Show1 = {'PD_durations','LP_delay_on','LP_delay_off'};
Show2 = {'PD_duty_cycle','LP_phase_on','LP_phase_off'};
C = lines;
X = p.PD_burst_period;

ax.delays = subplot(3,4,6); hold on
clear h
for i = 1:length(Show1)
	Y = p.(Show1{i});
	plot(X,Y,'.','Color',C(i,:));
	ff = fit(X(:),Y(:),'poly1');
	plot([0 2],ff([0 2]),'Color',C(i,:))

	% fake plot
	h(i) = plot(NaN,NaN,'.','Color',C(i,:),'MarkerSize',34);

end
lh = legend(h,{'PD off','LP on','LP off'},'Location','northwest');


% phases vs periods to show constancy?

ax.phases = subplot(3,4,10); hold on

for i = 1:length(Show2)
	Y = p.(Show2{i});
	plot(X,Y,'.','Color',C(i,:))
	ff = fit(X(:),Y(:),'poly1');
	plot([0 2],ff([0 2]),'Color',C(i,:))
end



ax.nspikes = subplot(3,4,7); hold on
ax.dc = subplot(3,4,11); hold on
ax.LP_phase = subplot(3,4,8); hold on
ax.LP_nspikes = subplot(3,4,12); hold on

figlib.pretty('FontSize',14)



% metrics
axes(ax.nspikes)
plotlib.scatterhist(p.PD_nspikes,p.LP_nspikes,'NumBins',20,'TickPrecision',1)
xlabel(ax.nspikes,'#spikes/burst (PD)')
ylabel(ax.nspikes,'#spikes/burst (LP)')


axes(ax.dc)
plotlib.scatterhist(p.PD_duty_cycle,p.LP_duty_cycle,'NumBins',20,'TickPrecision',3)
xlabel(ax.dc,'Duty cycle (PD)')
ylabel(ax.dc,'Duty cycle (LP)')



axes(ax.LP_phase)
plotlib.scatterhist(p.LP_phase_on,p.LP_duty_cycle,'NumBins',20,'TickPrecision',2)
xlabel('LP phase on')
ylabel('LP duty cycle')


axes(ax.LP_nspikes)
plotlib.scatterhist(p.LP_nspikes,p.LP_duty_cycle,'NumBins',20,'TickPrecision',2)
xlabel('#spikes/burst (LP)')
ylabel('LP duty cycle')


xlabel(ax.delays,'Burst period (s)')
xlabel(ax.phases,'Burst period (s)')
ax.phases.YLim = [0 1];
ax.delays.YLim = [0 1.3];
ylabel(ax.delays,'Delays (s)')
ylabel(ax.phases,'Phase')
ax.delays.XAxisLocation = 'top';
ax.delays.Position(2) = .35;
ax.raincloud.Position(3) = .13;
ax.delays.Position(1) = .31;
ax.phases.Position(1) = .31;


% clean up some tick marks
ax.nspikes.YTick(end-1)=[];
ax.nspikes.XTick(end-1)=[];
ax.dc.XTick(2) = [];
ax.dc.XTick(end-1) = [];
ax.dc.YTick(2) = [];
ax.dc.YTick(end-1) = [];
ax.LP_nspikes.YTick(2) = [];
ax.LP_phase.YTick(2) = [];
ax.LP_phase.XTick(2) = [];