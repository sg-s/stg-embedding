% test script for matlab wrapper 

% this sets up the STG network 
% as in Fig 2e of this paper:
% Prinz ... Marder Nat Neuro 2004
% http://www.nature.com/neuro/journal/v7/n12/abs/nn1352.html


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


x.transpile;
x.compile;


x.dt = 50e-3;
x.t_end = 20e3;
x.closed_loop = false;
x.skip_hash_check = true;

% pick nice q10s so that everyting still spikes at 20°C

% q10s = NaN(60,10);

% for i = 1:10
% 	while true
% 		q = rand(60,1) + 1;
% 		x.setQ10(q);
% 		x.temperature = 20;
% 		[V,Ca] = x.integrate;
% 		V = V(1e5:end,:);
% 		Ca = Ca(1e5:end,:);

% 		for j = 1:3
% 			bm = psychopomp.findBurstMetrics(V(:,j),Ca(:,j),Inf,Inf);
% 			n(j) = bm(2);
% 		end

% 		if min(n) > 2
% 			q10s(:,i) = q;
% 			figure, plot(V), drawnow
% 			break
% 		else
% 			disp(n)
% 		end

% 	end
% end


load('q10s.mat')


all_temp = linspace(10,30,500);

AB_spikes = sparse(20e3,500*10);
LP_spikes = sparse(20e3,500*10);
PY_spikes = sparse(20e3,500*10);
save('xolotl_temp_spikes.mat','AB_spikes','LP_spikes','PY_spikes')
idx = 1;

for i = 1:10

	disp(i)

	x.setQ10(q10s(:,i));
	x.reset;

	x.closed_loop = true;

	for j = 1:length(all_temp)


		textbar(j,length(all_temp))

		x.temperature = all_temp(j);
		V = x.integrate;

		for k = 1:3
			s = psychopomp.findNSpikes(V(:,k),2e3);
			s = floor(nonnans(s)*x.dt);
			s(s==0) = 1;
			

			if k == 1
				AB_spikes(s,idx) = 1;
			elseif k == 2
				LP_spikes(s,idx) = 1;
			else
				PY_spikes(s,idx) = 1;
			end

		end

		idx = idx + 1;

	end


	save('xolotl_temp_spikes.mat','AB_spikes','LP_spikes','PY_spikes','-append')


end

all_temp = linspace(10,30,500);
all_temp = vectorise(repmat(all_temp,1,10));

% augment the data by vectorising, and then sliding
% in overlapping steps


slide_step = 5e3; % 5 sec
window_size = 20e3;

t_starts = 1:slide_step:(20e3*500 - window_size + 1);


reshaped_AB = sparse(window_size,length(t_starts));
reshaped_LP = sparse(window_size,length(t_starts));
reshaped_PY = sparse(window_size,length(t_starts));

all_temp = linspace(10,30,500);
all_temp = vectorise(repmat(all_temp,20e3,1));

for i = 1:10
	disp(i)
	a = (i-1)*500 + 1;
	z = i*500;
	this_AB = vectorise(AB_spikes(:,a:z));
	this_LP = vectorise(LP_spikes(:,a:z));
	this_PY = vectorise(PY_spikes(:,a:z));

	

	for j = 1:length(t_starts)
		textbar(j,length(t_starts))
		idx = (i-1)*length(t_starts) + j;

		a = t_starts(j);
		z = t_starts(j) + 20e3 - 1;

		reshaped_AB(:,idx) = this_AB(a:z);
		reshaped_LP(:,idx) = this_LP(a:z);
		reshaped_PY(:,idx) = this_PY(a:z);

	end

end



