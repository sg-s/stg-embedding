% this figure shows correlations (if any) between pairs of metrics
% in the baseline data for a prep-by-prep basis


close all
init()


prepmetrics = struct;
fn = fieldnames(basemetrics);
fn = setdiff(fn,{'PD_phase_on','LP_burst_period','LP_delay_on','LP_delay_off','PD_nspikes','LP_nspikes','PD_durations','LP_durations','PD_delay_on'});
for i = 1:length(fn)
	prepmetrics.(fn{i}) = analysis.averageBy(basemetrics.(fn{i}),basedata.experiment_idx);
end


% compute correlations and p-values between all pairs
Rho = zeros(length(fn));
pvals = zeros(length(fn));
for i = 1:length(fn)
	for j = 1:length(fn)
		if i == j
			continue
		end

		X = prepmetrics.(fn{i});
		Y = prepmetrics.(fn{j});
		rm_this = isnan(X) | isnan(Y);


		[Rho(i,j), pvals(i,j)] = corr(X(~rm_this),Y(~rm_this),'Type','Spearman');

	end
end


figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on


% positivelt coerrelated
subplot(3,3,1); hold on

temp = Rho;
temp(Rho<0 | pvals > 0.01) = 0;
G = graph(temp);
p = plot(G,'Layout','circle'); 
XData = p.XData;
YData = p.YData;
delete(p)
p = plot(G); 
p.XData = XData;
p.YData = YData;
W = G.Edges.Weight;

p.LineWidth = W*7;
p.EdgeColor = 1-repmat(W,1,3);

p.NodeLabel = fn;
p.Interpreter = 'none';
p.MarkerSize = 10;
p.NodeFontSize = 12;
axis off
axis square
title('\rho > 0')




subplot(3,3,4); hold on
th = display.scatterWithCorrelation(prepmetrics.LP_phase_off,prepmetrics.LP_duty_cycle);
th.Position = [.1 .8];
xlabel('LP phase off')
ylabel('LP duty cycle')
set(gca,'XLim',[0 1],'YLim',[0 1])
axis square

subplot(3,3,7); hold on
th = display.scatterWithCorrelation(prepmetrics.LP_phase_on,prepmetrics.PD_duty_cycle);
xlabel('LP phase on')
ylabel('PD duty cycle')
set(gca,'XLim',[0 1],'YLim',[0 1])
th.Position = [.1 .8];
axis square



% uncorrelated
subplot(3,3,2); hold on

temp = abs(Rho);
temp(pvals < 0.05) = 0;
G = graph(temp);
p = plot(G,'Layout','circle'); 
XData = p.XData;
YData = p.YData;
delete(p)
p = plot(G); 
p.XData = XData;
p.YData = YData;
W = abs(G.Edges.Weight);

p.LineWidth = W*7;
p.EdgeColor = [.5 .5 .5];

p.NodeLabel = fn;
p.Interpreter = 'none';
p.MarkerSize = 10;
p.NodeFontSize = 12
axis off
axis square
title('\rho \approx 0')

subplot(3,3,5); hold on
th = display.scatterWithCorrelation(prepmetrics.PD_duty_cycle,prepmetrics.LP_duty_cycle);
th.Position = [.1 .8];
xlabel('PD duty cycle')
ylabel('LP duty cycle')
set(gca,'XLim',[0 1],'YLim',[0 1])
axis square

subplot(3,3,8); hold on
display.scatterWithCorrelation(prepmetrics.PD_burst_period,prepmetrics.LP_duty_cycle)
xlabel('PD burst period (s)')
ylabel('LP duty cycle')
axis square
set(gca,'YLim',[0 1])


% negatively correlated

subplot(3,3,3); hold on

temp = Rho;
temp(Rho>0 | pvals > 0.01) = 0;
G = graph(abs(temp));
p = plot(G,'Layout','circle'); 
XData = p.XData;
YData = p.YData;
delete(p)
p = plot(G); 
p.XData = XData;
p.YData = YData;
W = G.Edges.Weight;

p.LineWidth = W*7;
p.EdgeColor = 1-repmat(W,1,3);

p.NodeLabel = fn;
p.Interpreter = 'none';
p.MarkerSize = 10;
p.NodeFontSize = 12
axis off
axis square
title('\rho < 0')

subplot(3,3,6); hold on
display.scatterWithCorrelation(prepmetrics.LP_duty_cycle,prepmetrics.LP_phase_on)
xlabel('LP duty cycle')
ylabel('LP phase on')
set(gca,'XLim',[0 1],'YLim',[0 1])
axis square

subplot(3,3,9); hold on
display.scatterWithCorrelation(prepmetrics.PD_duty_cycle,prepmetrics.PD_burst_period)
xlabel('PD duty cycle')
ylabel('PD burst period (s)')
set(gca,'XLim',[0 1])
axis square

figlib.pretty()

% cleanup
figlib.saveall('Location',display.saveHere)

% another init to clear away all extra variables
init()


