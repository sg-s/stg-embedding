% show baseline stats by prep for all data

lp_color = color.aqua('red');
pd_color = color.aqua('indigo');

if ~exist('burst_metrics','var')
	normaldata = alldata.purge(alldata.idx ~='normal');
	burst_metrics = normaldata.ISI2BurstMetrics;
	burst_metrics = structlib.scalarify(burst_metrics);
end

figure('outerposition',[300 300 1500 901],'PaperUnits','points','PaperSize',[1500 901]); hold on


subplot(3,1,1); hold on
[h,P] = display.plotStateDistributionByPrep(alldata.idx, alldata.experiment_idx,true(length(alldata.mask),1));

[~,sort_order]= sort(P(:,1),'descend');
delete(h)
P = P(sort_order,:);
h = bar(P,'stacked','LineStyle','-','BarWidth',1);


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
subplot(3,4,[5 9]); hold on
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
set(gca,'YTick',[2:2:2*length(fn)],'YTickLabel',L)






% compare latencies and phases and show phase constancy
Show1 = {'PD_durations','LP_delay_on','LP_delay_off'};
Show2 = {'PD_duty_cycle','LP_phase_on','LP_phase_off'};
C = lines;
X = p.PD_burst_period;

subplot(3,4,6); hold on
for i = 1:length(Show1)
	Y = p.(Show1{i});
	plot(X,Y,'.','Color',C(i,:))
	ff = fit(X(:),Y(:),'poly1');
	plot([0 2],ff([0 2]),'Color',C(i,:))

end



% phases vs periods to show constancy?

subplot(3,4,10); hold on

for i = 1:length(Show2)
	Y = p.(Show2{i});
	plot(X,Y,'.','Color',C(i,:))
	ff = fit(X(:),Y(:),'poly1');
	plot([0 2],ff([0 2]),'Color',C(i,:))
end







% metrics
subplot(3,4,7); hold on
plotlib.scatterhist(p.PD_nspikes,p.LP_nspikes,'NumBins',20)


subplot(3,4,11); hold on
plotlib.scatterhist(p.PD_duty_cycle,p.LP_duty_cycle,'NumBins',20)



subplot(3,4,8); hold on
plotlib.scatterhist(p.LP_phase_on,p.LP_duty_cycle,'NumBins',20)


subplot(3,4,12); hold on
plotlib.scatterhist(p.LP_nspikes,p.LP_duty_cycle,'NumBins',20)