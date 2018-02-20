
pHeader;

%% 
% In this document, I look at how one can estimate phases of oscillating (bursting) neurons from their spike times, and how one can measure phase differences between two oscillating neurons.

%% The data
% The data I use here is intracellular recordings of LP and PD neurons from Jess Haley. I show a short raster of this data below:

dm = dataManager;
dm.verbosity = 0;
path_name = dm.getPath('17fc38dc295b93f8234588c5b4f6455e');
if ~exist('c','var')
	c = crabsort(false);
	[c.path_name, file_name, file_ext] = fileparts(path_name);
	c.file_name = [file_name file_ext];
	c.loadFile;
end

PD = c.spikes.PD.PD*c.dt;
LP = c.spikes.LP.LP*c.dt;

PD(PD > 400) = [];
LP(LP > 400) = [];

% convert into ms
PD = floor(PD*1e3);
LP = floor(LP*1e3);

z = max([length(PD); length(LP)]);

PD = [PD; zeros(z-length(PD),1)];
LP = [LP; zeros(z-length(LP),1)];


PD_zp = PD;
LP_zp = LP;
PD = nonzeros(PD);
LP = nonzeros(LP);


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
raster(PD_zp,LP_zp,'deltat',1e-3)
set(gca,'YTick',[.5 1.5],'YTickLabel',{'PD','LP'})
set(gca,'XLim',[0 5])
xlabel('Time (s)')
prettyFig()



if being_published	
	snapnow	
	delete(gcf)
end




%%
% Now I plot the ISI distributions of PD and LP.



figure('outerposition',[300 300 600 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
[hy,hx] = histcounts(diff(PD),100);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2)

[hy,hx] = histcounts(diff(LP),100);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));

stairs(hx,hy,'LineWidth',2)

xlabel('ISI (ms)')
ylabel('Probability')
legend({'PD','LP'})

prettyFig();


if being_published	
	snapnow	
	delete(gcf)
end


%%
% Note that it is extremely bimodal -- corresponding to bursting and spiking. This lets one cleanly identify bursts in the time trace by finding the time of the first and last spike of every burst. There are some weird things -- note that the "burst ISI" of the two neurons don't match up exaclty -- which is suprising, because on would expect them to be coupled. 

%% Measuring periods: the classical way
% Now, I use the timing of the first and last spikes to measure the period of the PD and LP neurons, as is done traditionally. Since every burst of a neuron has a first and a last spike, there are two indepndent ways of measuring the period. In (a), I plot histograms of the burst period as measured using the first spike (green) and the last spike (red) for the entire dataset. Note that the periods estiamted from the last spike are a lot more variable -- this is because spiking is a probabilistic process, and a close inspection of the bursts of PD reveals that sometimes, the "last" spike doesn't occur. Plotting the periods measured in these two ways reveals striking correlations (b), that once again arise from the fact that spiking is probabilistic. A similar effect, albiet much weaker, is observed for LP (c-d). 

PD_offs = PD(computeOnsOffs(diff(PD)>250));
PD_ons = PD(computeOnsOffs(diff(PD)<250));

% make sure we have vectors the same length, and PD turns on before LP
while PD_ons(1) > PD_offs(1)
	PD_offs(1) = [];
end

LP_offs = LP(computeOnsOffs(diff(LP)>250));
LP_ons = LP(computeOnsOffs(diff(LP)<250));

while LP_ons(1) > LP_offs(1)
	LP_offs(1) = [];
end

while LP_ons(1) < PD_ons(1)
	LP_ons(1) = [];
end

while LP_offs(1) < PD_ons(1)
	LP_offs(1) = [];
end

% trim all vectors to the same length
z = min([length(PD_ons),length(PD_offs), length(LP_ons), length( LP_offs)]);
LP_ons = LP_ons(1:z);
LP_offs = LP_offs(1:z);
PD_offs = PD_offs(1:z);
PD_ons = PD_ons(1:z);


figure('outerposition',[300 300 1200 1209],'PaperUnits','points','PaperSize',[1200 1209]); hold on

subplot(2,2,1); hold on
[hy,hx] = histcounts(diff(PD_ons),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[0 1 0])

[hy,hx] = histcounts(diff(PD_offs),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[1 0 0 ])
legend({'First spike','Last spike'})
title('PD')
xlabel('Burst period (ms)')
ylabel('Probability')

% now plot it vs each other
subplot(2,2,2); hold on
plot(diff(PD_ons),diff(PD_offs),'k.')
xlabel('Period measured using first spike in burst (ms)')
ylabel('Period measured using last spike in burst (ms)')
set(gca,'XLim',[500 800],'YLim',[500 800])
title('PD')

subplot(2,2,3); hold on
[hy,hx] = histcounts(diff(LP_ons),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[0 1 0])

[hy,hx] = histcounts(diff(LP_offs),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[1 0 0 ])
legend({'First spike','Last spike'})
title('LP')
xlabel('Burst period (ms)')
ylabel('Probability')

% now plot it vs each other
subplot(2,2,4); hold on
plot(diff(LP_ons),diff(LP_offs),'k.')
xlabel('Period measured using first spike in burst (ms)')
ylabel('Period measured using last spike in burst (ms)')
set(gca,'XLim',[500 800],'YLim',[500 800])
title('LP')


prettyFig();
labelFigure('x_offset',-.01,'y_offset',.01,'font_size',28)

if being_published
	snapnow
	delete(gcf)
end

%% Measuring phases: the classical way
% Now we measure "phases" using the traditional way by finding the time delay between the last spike in PD and the first spike in LP, and normalizing by the burst period. 


trad_phase_diff_ons = LP_ons - PD_ons;
trad_phase_diff_ons(end) = NaN;
trad_phase_diff_ons(1:end-1) = trad_phase_diff_ons(1:end-1)./diff(PD_ons);
trad_phase_diff_ons(trad_phase_diff_ons>1) = trad_phase_diff_ons(trad_phase_diff_ons>1) - 1;

trad_phase_diff_offs = LP_offs - PD_offs;
trad_phase_diff_offs(end) = NaN;
trad_phase_diff_offs(1:end-1) = trad_phase_diff_offs(1:end-1)./diff(PD_offs);
trad_phase_diff_offs(trad_phase_diff_offs>1) = trad_phase_diff_offs(trad_phase_diff_offs>1) - 1;


figure('outerposition',[300 300 1001 900],'PaperUnits','points','PaperSize',[1200 900]); hold on
subplot(2,2,1); hold on
[hy,hx] = histcounts((trad_phase_diff_ons),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[0 1 0])

[hy,hx] = histcounts((trad_phase_diff_offs),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[1 0 0])

legend({'Using first spike','Using last spike'})

xlabel('PD > LP Phase difference  (norm)')
ylabel('Probability')
set(gca,'XLim',[.3 1])

subplot(2,2,2); hold on
plot(diff(PD_ons),trad_phase_diff_ons(1:end-1),'go')
xlabel('Period (ms)')
ylabel('PD > LP Phase difference  (norm)')
set(gca,'YLim',[.3 1])
title('Using first spike in burst')

subplot(2,2,3); hold on
plot(diff(PD_offs),trad_phase_diff_offs(1:end-1),'ro')
xlabel('Period (ms)')
ylabel('PD > LP Phase difference  (norm)')
set(gca,'YLim',[.3 1])
title('Using last spike in burst')

subplot(2,2,4); hold on
plot(trad_phase_diff_ons,trad_phase_diff_offs,'ko')
set(gca,'XLim',[.3 1],'YLim',[.3 1])
xlabel('Phase diff. (first spike)')
ylabel('Phase diff. (last spike)')

prettyFig();

if being_published
	snapnow
	delete(gcf)
end


%% Extracting periods using the Hilbert transform 
% In this section, I attempt to extract periods of the neurons from their spike trains, but by first extracting the true phase of the neuron using the Hilbert transform. For a discussion on extracting phases and amplitudes from time series, see "Synchronization"  by Pikovsky, Rosenblum & Kurths (Appendix A2). 


PD_embed = zeros(400e3,1);
PD_embed(PD) = 1;

LP_embed = zeros(400e3,1);
LP_embed(LP) = 1;

time = (1:length(PD_embed))*1e-3;

PDs = spiketimes2f(PD_embed,time,1e-3,1e-1);
LPs = spiketimes2f(LP_embed,time,1e-3,1e-1);

[A_LP, p_LP, H_LP] = phasify(LPs);
[A_PD, p_PD, H_PD] = phasify(PDs);

% align phases to burst onset (phase = 0 at start of burst)

phase_offset = -pi - mean(p_PD(PD_ons));
p_PD = p_PD + phase_offset;
p_PD(p_PD < -pi) =  p_PD(p_PD < -pi) + 2*pi;

p_LP = p_LP + phase_offset;
p_LP(p_LP < -pi) =  p_LP(p_LP < -pi) + 2*pi;


%%
% In the following figure, I compare the rasters of PD and LP to the extracted phases of LP and PD. Note that the phase of PD is 0 at the onset of PD bursting (by construction). Note however, that the phase of LP also tends to be 0 at the onset of LP bursting -- which naturally comes out of the data, showing that the phase reconstruction captures the burst onsets well.

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(2,1,1); hold on
raster(PD_zp,LP_zp,'deltat',1e-3)
set(gca,'YTick',[.5 1.5],'YTickLabel',{'PD','LP'})
set(gca,'XLim',[10 20])


subplot(2,1,2); hold on
plot(time, p_PD)
plot(time, p_LP)
set(gca,'XLim',[10 20],'YTick',[-pi 0 pi],'YTickLabel',[0 .5 1],'YLim',[-pi pi])
xlabel('Time (s)')
ylabel('Phase')
prettyFig();

if being_published
	snapnow
	delete(gcf)
end

%%
% In (a), I compare the periods extracted from the first and last spikes (green, red), and from the Hilbert transform. Note that the periods from the Hilbert transform agree well with the traditional way, but the distribution is more well-behaved and more mono-modal. In (b), I plot the true phase vs. the normalized time since phase onset. The error bars are standard deviations across all periods, and the dotted line is the assumption of linearity (as in the traditional method). Finally, in the panel on the right, I plot the amplitude-phase diagram of the time series, showing every oscilaltion. Data from PD is shown in (a-b), and data from LP is shown in (c-d). 

N = 100;
PD_T = NaN(1e6,1);
for i = 1:N
	temp = p_PD + rand*2*pi;
	temp(temp>pi) = temp(temp>pi) - 2*pi;
	[~,temp] = findpeaks(temp,'MinPeakProminence',pi);
	a = find(isnan(PD_T),1,'first');
	z = a + length(temp) - 2;
	PD_T(a:z) = diff(temp);
end
PD_T = nonnans(PD_T);

LP_T = NaN(1e6,1);
for i = 1:N
	temp = p_LP + rand*2*pi;
	temp(temp>pi) = temp(temp>pi) - 2*pi;
	[~,temp] = findpeaks(temp,'MinPeakProminence',pi);
	a = find(isnan(LP_T),1,'first');
	z = a + length(temp) - 2;
	LP_T(a:z) = diff(temp);
end
LP_T = nonnans(LP_T);


figure('outerposition',[300 300 1800 1202],'PaperUnits','points','PaperSize',[1800 1202]); hold on
subplot(2,3,1); hold on

[hy,hx] = histcounts(diff(PD_ons),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[0 1 0])

[hy,hx] = histcounts(diff(PD_offs),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[1 0 0])


[hy,hx] = histcounts((PD_T),200);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));

stairs(hx,hy,'LineWidth',3,'Color',[0 0 0])
xlabel('Period of PD (ms)')
ylabel('Probability')
legend({'Using first spike','using last spike','Hilbert transform'})
title('PD')
set(gca,'XLim',[500 800])

% now plot the phase curve
[~,PD_phase_peaks] = findpeaks(p_PD,'MinPeakProminence',3);
X = zeros(100,length(PD_phase_peaks)-1);
for i = 1:length(PD_phase_peaks)-1
	a = PD_phase_peaks(i)+1;
	z = PD_phase_peaks(i+1);
	temp = p_PD(a:z);
	X(:,i) = interp1(1:length(temp),temp,linspace(1,length(temp),100));
end

subplot(2,3,2); hold on
errorShade(linspace(0,1,100),mean(X,2),std(X'));
plot([0 1],[-pi pi],'k--')
xlabel('Fraction of time since phase onset')
ylabel('True phase (radian)')
X_PD = X;

% show the phase portrait
subplot(2,3,3); 
p = polarplot(p_PD(1e3:end-1e3),A_PD(1e3:end-1e3));
p.Color = [p.Color(1:3) .3];


% now do LP

subplot(2,3,4); hold on

[hy,hx] = histcounts(diff(LP_ons),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[0 1 0])

[hy,hx] = histcounts(diff(LP_offs),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
stairs(hx,hy,'LineWidth',2,'Color',[1 0 0])


[hy,hx] = histcounts((LP_T),200);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));

stairs(hx,hy,'LineWidth',3,'Color',[0 0 0])
xlabel('Period of LP (ms)')
ylabel('Probability')
legend({'Using first spike','using last spike','Hilbert transform'})
title('LP')
set(gca,'XLim',[500 800],'YLim',[0 .05])

% now plot the phase curve
[~,LP_phase_peaks] = findpeaks(p_LP,'MinPeakProminence',3);
X = zeros(100,length(LP_phase_peaks)-1);
for i = 1:length(LP_phase_peaks)-1
	a = LP_phase_peaks(i)+1;
	z = LP_phase_peaks(i+1);
	temp = p_LP(a:z);
	X(:,i) = interp1(1:length(temp),temp,linspace(1,length(temp),100));
end
X_LP = X;

subplot(2,3,5); hold on
errorShade(linspace(0,1,100),mean(X,2),std(X'));
plot([0 1],[-pi pi],'k--')
xlabel('Fraction of time since phase onset')
ylabel('True phase (radian)')

% show the phase portrait
subplot(2,3,6); 
p = polarplot(p_LP(1e3:end-1e3),A_LP(1e3:end-1e3));
p.Color = [p.Color(1:3) .3];

prettyFig();
labelFigure('x_offset',-.01,'y_offset',.01,'font_size',28)

if being_published
	snapnow
	delete(gcf)
end


%% Computing phases differences using the Hilbert transform
% In this section, I measure phase differences from the continuous estimate of phase that the Hilbert transform gives me for each neuron. Since we know the phases of every neuron at every time point, the phase difference is simply the difference of these two time series. (a) compares the phase differences extracted from the Hilbert transform to the phase differences measured from the first and last spikes. Note that the Hilbert-transform phase differneces are inbetween the phase differences as reported by the first and last spikes, which makes sense. In (b), I compare the phase differences between the spike trains and between the raw intracellular voltage. Note that they don't exactly match up, and the distribution for the intracellular voltage is much tighter -- consistent with the idea of stochastic spike generation underyling variability in phase responses. 

direct_phase_diff = (unwrap(p_PD) - unwrap(p_LP));
direct_phase_diff = direct_phase_diff/(2*pi);
direct_phase_diff = 1 + direct_phase_diff;

% smooth
T = floor(mean(PD_T));
K = ones(T,1);
direct_phase_diff = filtfilt(K,length(K),direct_phase_diff);
direct_phase_diff = direct_phase_diff(T:end-2*T);

% Phase differences from the intracellular trace 
% LP

LP_int = c.raw_data(c.time<=400,1);
LP_int = LP_int(1:10:end);
K = ones(50,1);

LP_int = LP_int - mean(LP_int);
LP_int = LP_int/std(LP_int);

LP_smooth = fastFiltFilt(K,1,LP_int);
LP_smooth = LP_smooth - mean(LP_smooth);
LP_smooth = LP_smooth/std(LP_smooth);


PD_int = c.raw_data(c.time<=400,2);
PD_int = PD_int(1:10:end);

PD_int = PD_int - mean(PD_int);
PD_int = PD_int/std(PD_int);

PD_smooth = fastFiltFilt(K,1,PD_int);
PD_smooth = PD_smooth - mean(PD_smooth);
PD_smooth = PD_smooth/std(PD_smooth);

[A_LP_int, p_LP_int, H_LP_int] = phasify(LP_smooth);
[A_PD_int, p_PD_int, H_PD_int] = phasify(PD_smooth);

direct_phase_diff_int = unwrap(p_LP_int) - unwrap(p_PD_int);
direct_phase_diff_int = direct_phase_diff_int/(2*pi);
direct_phase_diff_int = 1 + direct_phase_diff_int;

% smooth
T = floor(mean(PD_T));
K = ones(T,1);
direct_phase_diff_int = filtfilt(K,length(K),direct_phase_diff_int);
direct_phase_diff_int = direct_phase_diff_int(T:end-2*T);


figure('outerposition',[300 300 1001 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
clear ax l l2
for i = 2:-1:1
	ax(i) = subplot(1,2,i); hold on
	xlabel(ax(i),'Phase difference b/w PD and LP')
	set(gca,'XLim',[.3 .7])
	ylabel('Probability')
end
[hy,hx] = histcounts((trad_phase_diff_ons),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
l(1) = stairs(ax(1),hx,hy,'LineWidth',2,'Color',[0 1 0]);

[hy,hx] = histcounts((trad_phase_diff_offs),40);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
l(2) = stairs(ax(1),hx,hy,'LineWidth',2,'Color',[1 0 0]);

[hy,hx] = histcounts((direct_phase_diff),200);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
l(3) = stairs(ax(1),hx,hy,'LineWidth',3,'Color',[0 0 0]);
l2(1) = stairs(ax(2),hx,hy,'LineWidth',3,'Color',[0 0 0]);

legend({'Using first spike','Using last spike','Hilbert transform'})


[hy,hx] = histcounts((direct_phase_diff_int),200);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
l2(2) = stairs(ax(2),hx,hy,'LineWidth',3,'Color',[0 0 1]);

legend(l2,{'Hilbert transform spikes','Hilbert transform of intracellular'})

prettyFig();
labelFigure('x_offset',-.01,'y_offset',.01,'font_size',28)

if being_published
	snapnow
	delete(gcf)
end

%% Estimating phases differences form cross correlation functions
% In this section, I use the crosscorrelation function to estimate the phase difference between LP and PD. Note that both delays and periods can be inferred from a single cross correlation function, and I define the phase offset as the ratio of the delay to the period for that snippet. Note that the phase differences calcualted this way agree with the phase differences calcualted using the Hilbert transform. 

X = PD_smooth;
Y = LP_smooth;

window_size = 2e3;

X = stagger(X, window_size, 1e3);
Y = stagger(Y, window_size, 1e3);

XY = NaN(window_size,size(X,2));

parfor i = 1:size(X,2)
	X(:,i) = X(:,i) - mean(X(:,i));
	X(:,i) = X(:,i)/std(X(:,i));
	Y(:,i) = Y(:,i) - mean(Y(:,i));
	Y(:,i) = Y(:,i)/std(Y(:,i));

	temp = xcorr(X(:,i),Y(:,i));
	XY(:,i) = temp(window_size:end)/window_size;

end

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(1,2,1); hold on
plot(1:window_size,XY,'Color',[0.5 0 0 .1])
xlabel('Lag (ms)')
ylabel('Cross correlation (norm)')

[~,loc] = max(XY);

[~,loc2] = min(XY(400:800,:));
loc2 = loc2 + 400;

phase_diff_xcorr = loc./loc2;

subplot(1,2,2); hold on
clear l
[hy,hx] = histcounts((phase_diff_xcorr),20);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
l(2) = stairs(hx,hy,'LineWidth',3,'Color',[1 0 0]);

[hy,hx] = histcounts((direct_phase_diff_int),200);
hx = hx(1:end-1) + mean(diff(hx));
hy = (hy/sum(hy))/mean(diff(hx));
l(1) = stairs(hx,hy,'LineWidth',3,'Color',[0 0 1]);
ylabel('Probability')
xlabel('Phase difference b/w LP & PD')
set(gca,'XLim',[0.4 .6])
legend(l,{'Hilbert transform of intracellular','Cross correlation intracellular'})

prettyFig();
labelFigure('x_offset',-.01,'y_offset',.01,'font_size',28)

if being_published
	snapnow
	delete(gcf)
end

%% Version Info
%
pFooter;


