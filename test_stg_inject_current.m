% this script uses a stg model
% and injects more and more current into it
% and gets all the spike times from it
% this is our synthetic data, a poor man's
% substitute for temperature control 

% test script for matlab wrapper 

% this sets up the STG network 
% as in Fig 2e of this paper:
% Prinz ... Marder Nat Neuro 2004
% http://www.nature.com/neuro/journal/v7/n12/abs/nn1352.html

all_I_ext = [0 logspace(-3,2,149) logspace(2,-3,149) 0];

if ~exist('all_spikes.mat','file') 

	% conversion from Prinz to phi
	vol = 1; % this can be anything, doesn't matter
	f = 14.96; % uM/nA
	tau_Ca = 200;
	F = 96485; % Faraday constant in SI units
	phi = (2*f*F*vol)/tau_Ca;

	x = xolotl;
	x.addCompartment('AB',-65,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);

	x.addConductance('AB','prinz/NaV',1000,50);
	x.addConductance('AB','prinz/CaT',25,30);
	x.addConductance('AB','prinz/CaS',60,30);
	x.addConductance('AB','prinz/ACurrent',500,-80);
	x.addConductance('AB','prinz/KCa',50,-80);
	x.addConductance('AB','prinz/Kd',1000,-80);
	x.addConductance('AB','prinz/HCurrent',.1,-20);

	x.addCompartment('LP',-47,0.01,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);
	x.addConductance('LP','prinz/NaV',1000,50);
	x.addConductance('LP','prinz/CaS',40,30);
	x.addConductance('LP','prinz/ACurrent',200,-80);
	x.addConductance('LP','prinz/Kd',250,-80);
	x.addConductance('LP','prinz/HCurrent',.5,-20);
	x.addConductance('LP','Leak',.3,-50);

	x.addCompartment('PY',-41,0.03,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);
	x.addConductance('PY','prinz/NaV',1000,50);
	x.addConductance('PY','prinz/CaT',25,30);
	x.addConductance('PY','prinz/CaS',20,30);
	x.addConductance('PY','prinz/ACurrent',500,-80);
	x.addConductance('PY','prinz/Kd',1250,-80);
	x.addConductance('PY','prinz/HCurrent',.5,-20);
	x.addConductance('PY','Leak',.1,-50);



	% 2e
	x.addSynapse('Chol','AB','LP',30);
	x.addSynapse('Chol','AB','PY',3);
	x.addSynapse('Glut','AB','LP',30);
	x.addSynapse('Glut','AB','PY',10);
	x.addSynapse('Glut','LP','PY',1);
	x.addSynapse('Glut','PY','LP',30);
	x.addSynapse('Glut','LP','AB',30);

	x.I_ext = zeros(x.t_end/x.dt,3);

	x.dt = 50e-3;
	x.t_end = 20e3;
	x.closed_loop = true;

	x.transpile;
	x.compile;

	x.skip_hash_check = true;


	all_spikes = NaN(3e3,3,length(all_I_ext));

	for i = 1:length(all_I_ext)
		disp(i)
		x.I_ext = all_I_ext(i) + zeros(x.t_end/x.dt,3);
		V = x.integrate;
		for j = 1:3
			all_spikes(:,j,i) = psychopomp.findNSpikes(V(:,j),3e3);
		end

	end

	% convert the spike times into a ms timestamps -- we don't need as fine-grained a time resolution. 


	all_spikes = round(all_spikes*x.dt);

	save('all_spikes.mat','all_spikes')

end

load('all_spikes')

% plot them all 
figure('outerposition',[0 0 1600 999],'PaperUnits','points','PaperSize',[1600 999]); hold on

subplot(1,2,1); hold on
c = 1;
for idx = 1:10:length(all_I_ext)/2
	raster(all_spikes(:,1,idx),all_spikes(:,2,idx),all_spikes(:,3,idx),'deltat',1e-3,'yoffset',3*(c-1))
	c = c+1;
end
set(gca,'YDir','reverse')

subplot(1,2,2); hold on

for idx = length(all_I_ext)/2:10:length(all_I_ext)
	raster(all_spikes(:,1,idx),all_spikes(:,2,idx),all_spikes(:,3,idx),'deltat',1e-3,'yoffset',3*(c-1))
	c = c + 1;
end

prettyFig('plw',1);



%% 
% Now, measure the 14-dimensional point corresponding to each current injection amplitude 


X = NaN(size(all_spikes,3),17);

% create the spike->pseudovariable filter
clear p
p.tau = 100; % ms
p.n = 1;
p.A = 1;
K = filter_gamma(1:2e3,p);

all_spikes(all_spikes==0)= 1;

for i = 1:size(all_spikes,3)
	disp(i)
	AB = zeros(20e3,1);
	LP = zeros(20e3,1);
	PY = zeros(20e3,1);

	AB(nonnans(all_spikes(:,1,i))) = 1;
	LP(nonnans(all_spikes(:,2,i))) = 1;
	PY(nonnans(all_spikes(:,3,i))) = 1;

	AB = fastFilter(K,1,AB);
	LP = fastFilter(K,1,LP);
	PY = fastFilter(K,1,PY);

	[theta_AB,~,m_AB] = phasify(AB);
	[theta_LP,~,m_LP] = phasify(LP);
	[theta_PY,~,m_PY] = phasify(PY);

	% chuck the first half of the trace
	theta_AB(1:length(theta_AB)/2) = [];
	theta_LP(1:length(theta_LP)/2) = [];
	theta_PY(1:length(theta_PY)/2) = [];

	pd_AB_LP = 2*pi*(finddelay(theta_AB,theta_LP)/m_AB.T);
	pd_AB_PY = 2*pi*(finddelay(theta_AB,theta_PY)/m_AB.T);

	if pd_AB_LP < 0
		pd_AB_LP = pd_AB_LP + 2*pi;
	end


	if pd_AB_PY < 0
		pd_AB_PY = pd_AB_PY + 2*pi;
	end

	X(i,:) = [mean(AB) m_AB.T m_AB.circ_dev nanmean(m_AB.mean_rho) nanmean(m_AB.std_rho) nanmean(LP) m_LP.T m_LP.circ_dev nanmean(m_LP.mean_rho) nanmean(m_LP.std_rho) nanmean(PY) m_PY.T m_PY.circ_dev nanmean(m_PY.mean_rho) nanmean(m_PY.std_rho) pd_AB_LP pd_AB_PY];

end



% t-sne the data and color code by I_ext

X(isnan(X)) = -1;
R = mctsne(X',2e3,10);

figure('outerposition',[0 0 1000 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
c = parula(100);

cidx = log(all_I_ext);
cidx(isinf(cidx)) = min(cidx(~isinf(cidx))) - 1;
cidx = cidx - min(cidx);
cidx = cidx/max(cidx);
cidx = ceil(cidx*99) + 1;


% plot lines
plot(R(1,:),R(2,:),'Color',[.9 .9 .9])

for i = 1:length(all_I_ext)
	plot(R(1,i),R(2,i),'o','Color',c(cidx(i),:))
end

n_spikes = squeeze(sum(~isnan(all_spikes),1));
% normalize by each row
for i = 1:3
	n_spikes(i,:) = n_spikes(i,:)/max(n_spikes(i,:));
end


subplot(1,2,1); hold on
for i = 1:length(all_I_ext)
	plot(R(1,i),R(2,i),'o','Color',n_spikes(:,i))
end



return


%% Delay embedding -- choosing the right delay
% In this section, I try to determine what the right delay is when delay embedding a time series. 


%%
% First, I will generate synthetic data using a sine wave, and try to see if delay embedding can recover the period of the oscillation. 



%%
%For this experiment, I will convert the spikes of a bursting neuron (AB) into a Calcium-like variable by convolving with a filter with a timescale of 100ms. 

all_tau = unique(round(linspace(1e3,2e3,100)));
mean_rho = NaN*all_tau;
std_rho = NaN*all_tau;
circ_dev = NaN*all_tau;

B = zeros(x.t_end,1);
B(nonnans(all_spikes(:,1,1))) = 1;


Bf = fastFilter(K,1,B);

for i = 1:length(all_tau)
	[~,~, mean_r, std_r, circ_dev(i)] = phasify(Bf,all_tau(i));
	mean_rho(i) = nanmean(mean_r);
	std_rho(i) = nanmean(std_r);

end


%% Delay embedding experiments
% In this section, I try delay-embedding the spike times convolved with Alpha function with various time scales, and seeing what I can see for a bursting cell and for a tonically spiking cell. 


all_tau = 100; % ms

figure('outerposition',[0 0 1300 901],'PaperUnits','points','PaperSize',[1300 901]); hold on


S = zeros(x.t_end,1);
S(nonnans(all_spikes(:,1,21))) = 1;

B = zeros(x.t_end,1);
B(nonnans(all_spikes(:,1,1))) = 1;

for i = 1:length(all_tau)
	

	clear p
	p.tau = all_tau(i);
	p.n = 1;
	p.A = 1;
	K = filter_gamma(1:5e3,p);

	Sf = fastFilter(K,1,S);
	Bf = fastFilter(K,1,B);

	z = length(Sf)/2;
	Sf = Sf(z:end);
	Bf = Bf(z:end);

	Sf = Sf - mean(Sf);
	Bf = Bf - mean(Bf);

	subplot(2,length(all_tau),i); hold on
	

	plot(Sf,circshift(Sf,autoCorrelationTime(Sf)),'k');

	% compute the mean radius
	[~, ~, mean_rho] = phasify(Sf);
	title(oval(nanmean(mean_rho)))

	subplot(2,length(all_tau),i+length(all_tau)); hold on
	plot(Bf,circshift(Bf,autoCorrelationTime(Bf)),'k');

	[~, ~, mean_rho] = phasify(Bf);
	title(oval(nanmean(mean_rho)))

end

equalizeAxes



% Now we do the same delay embedding, but convert the 
% smoothed spike times into a pseudo phase, and calcualte
% the error in the reconstructed attractor 


all_tau = unique(round(logspace(0,3,50)));
mean_r_S = NaN*all_tau;
std_r_S = NaN*all_tau;
jitter_r_S = NaN*all_tau;
tau_S = NaN*all_tau; % autocorrelation time

mean_r_B = NaN*all_tau;
std_r_B = NaN*all_tau;
jitter_r_B = NaN*all_tau;
tau_B = NaN*all_tau;

for i = 1:length(all_tau)

	textbar(i,length(all_tau))

	clear p
	p.tau = all_tau(i);
	p.n = 1;
	p.A = 1;
	K = filter_gamma(1:10e3,p);

	Sf = fastFilter(K,1,S);
	Bf = fastFilter(K,1,B);

	z = length(Sf)/2;
	Sf = Sf(z:end);
	Bf = Bf(z:end);

	Sf = Sf - mean(Sf);
	Bf = Bf - mean(Bf);

	tau_S(i) = autoCorrelationTime(Sf);
	tau_B(i) = autoCorrelationTime(Bf);


	[~, ~, mean_rho, std_rho, rho_jitter] = phasify(Sf);
	mean_r_S(i) = nanmean(mean_rho);
	std_r_S(i) = nanmean(std_rho);
	jitter_r_S(i) = nanmean(rho_jitter);

	[~, ~, mean_rho, std_rho, rho_jitter] = phasify(Bf);
	mean_r_B(i) = nanmean(mean_rho);
	std_r_B(i) = nanmean(std_rho);
	jitter_r_B(i) = nanmean(rho_jitter);

end


% plot
figure('outerposition',[0 0 1000 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
subplot(1,3,1); hold on
plot(all_tau,mean_r_B,'k+')
plot(all_tau,mean_r_S,'r+')
set(gca,'XScale','log')
ylabel('Mean radius')
xlabel('\tau')

subplot(1,3,2); hold on
plot(all_tau,jitter_r_B,'k+')
plot(all_tau,jitter_r_S,'r+')
set(gca,'XScale','log')
ylabel('Radius variability')
xlabel('\tau')


subplot(1,3,3); hold on
plot(all_tau,tau_B,'k+')
plot(all_tau,tau_S,'r+')
set(gca,'XScale','log')
ylabel('Radius variability')
xlabel('\tau')


return


figure('outerposition',[0 0 1300 901],'PaperUnits','points','PaperSize',[1300 901]); hold on


S = zeros(x.t_end/x.dt,1);
S(nonnans(all_spikes(:,1,21))) = 1; 

B = zeros(x.t_end/x.dt,1);
B(nonnans(all_spikes(:,1,1))) = 1;

for i = 1:length(all_tau)
	


	subplot(2,length(all_tau),i); hold on
	

	plot(Sf,circshift(Sf,autoCorrelationTime(Sf)),'k');

	subplot(2,length(all_tau),i+length(all_tau)); hold on
	plot(Bf,circshift(Bf,autoCorrelationTime(Bf)),'k');

end

equalizeAxes


%% Phase relationships between neurons 
% In this section, I see if I can use delay embedding to capture phase information between two neurons. 