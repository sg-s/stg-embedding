

function x = makeSTG()


A = 0.0628;

channels = {'NaV','CaT','CaS','ACurrent','KCa','Kd','HCurrent'};
prefix = 'prinz-temperature/';
gbar(:,1) = [1000 25  60 500  50  1000 .1];
gbar(:,2) = [1000 0   40 200  0   250  .5];
gbar(:,3) = [1000 24  20 500  0   1250 .5];
E =         [50   30  30 -80 -80 -80   -20];

x = xolotl;

x.add('compartment','AB','Cm',10,'A',A);
x.add('compartment','LP','Cm',10,'A',A);
x.add('compartment','PY','Cm',10,'A',A);

compartments = x.find('compartment');
for j = 1:length(compartments)

	% add Calcium mechanism
	x.(compartments{j}).add('CalciumMech1');

	for i = 1:length(channels)
		x.(compartments{j}).add([prefix channels{i}],'gbar',gbar(i,j),'E',E(i));
	end
end

x.AB.add('Leak','gbar',0,'E',-50);
x.LP.add('Leak','gbar',.3,'E',-50);
x.PY.add('Leak','gbar',.1,'E',-50);


% set up synapses as in Fig. 2e
x.connect('AB','LP','prinz-temperature/Chol','gbar',30);
x.connect('AB','PY','prinz-temperature/Chol','gbar',3);
x.connect('AB','LP','prinz-temperature/Glut','gbar',30);
x.connect('AB','PY','prinz-temperature/Glut','gbar',10);
x.connect('LP','PY','prinz-temperature/Glut','gbar',1);
x.connect('PY','LP','prinz-temperature/Glut','gbar',30);
x.connect('LP','AB','prinz-temperature/Glut','gbar',30);


% randomize Qs
q_min = 1;
q_max = 3;

% make a Q vector for the channels and one for the synapses
q_channels = rand(18,1)*(q_max-q_min) + q_min;
q_synapses = rand(14,1)*(q_max-q_min) + q_min;

x.set('AB*Q_*',q_channels)
x.set('*synapses*Q*',q_synapses)

x.t_end = 5e3;
x.dt = .1;
