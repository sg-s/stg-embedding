



function data = makeData(varargin)

% synthetic.makeData
%
% This function makes synthetic spike data so that we can try out 
% our embedding techniques on this
%
% It creates data of the following types:
% 
% normal (with varying burst periods)
% spiking/bursting
% spiking/silent
% irregular/bursting
% irregular/spiking
% both irregular
% irregular/silent
% phase shifted
% bursting/silent
%
% These labels are returned in experiment_idx so you can
% figure out which spiketimes come from what


RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1984)); 

options.BurstPeriodRange = [.5 2]; % seconds
options.PhaseOffsets = [.2 .4 .6 .8]; % phase offset of LP
options.DutyCycle = .2; % duty cycle of both neurons
options.DefaultPhaseOffset = .4; 
options.NSamples = 1e4;
options.NSpikesPerBurst = 4:6;
options.SpiketimeJitter = 1e-1;
options.BinSize = 20; % seconds
options.SpikingRateRange = [1 10];

options = corelib.parseNameValueArguments(options,varargin{:});

categories = categorical({'normal','spiking/silent','spiking/bursting','irregular/bursting','irregular/spiking','irregular','irregular/silent','bursting/silent','phase-shifted'});



structlib.packUnpack(options)

% make arrays
PD = NaN(1e3,NSamples);
LP = PD;
experiment_idx = categorical(NaN(NSamples,1));


NPerCategory = floor(NSamples/length(categories));

% ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ 
% make normal data
all_T = linspace(BurstPeriodRange(1),BurstPeriodRange(2),NPerCategory);

for i = 1:NPerCategory


	this_PD = synthetic.bursting(all_T(i),NSpikesPerBurst,DutyCycle,SpiketimeJitter,BinSize);
	this_LP = synthetic.bursting(all_T(i),NSpikesPerBurst,DutyCycle,SpiketimeJitter,BinSize);

	% introduce the phase shift 
	this_LP = this_LP + DefaultPhaseOffset*all_T(i);

	this_LP(this_LP>BinSize) = [];
	this_PD(this_PD>BinSize) = [];


	% add to data
	PD(1:length(this_PD),i) = this_PD;
	LP(1:length(this_LP),i) = this_LP;
end

experiment_idx(1:NPerCategory) = categories(1);

assert(min(PD(:)) >=0,'FATAL:Negative spiketimes')
assert(min(LP(:)) >=0,'FATAL:Negative spiketimes')

% ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ 

% now we make spiking/silent state
all_f = linspace(SpikingRateRange(1),SpikingRateRange(2),NPerCategory);
all_f = veclib.shuffle(all_f);

for i = 1:NPerCategory
	% PD spiking, LP silent
	this_PD = synthetic.spiking(all_f(i),BinSize,SpiketimeJitter);

	PD(1:length(this_PD),i+NPerCategory) = this_PD;

end
experiment_idx(NPerCategory+1:NPerCategory*2) = categories(2);
assert(min(PD(:)) >=0,'FATAL:Negative spiketimes')
assert(min(LP(:)) >=0,'FATAL:Negative spiketimes')


% ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ 
% now we make the spiking/bursting state
all_f = linspace(SpikingRateRange(1),SpikingRateRange(2),NPerCategory);
all_f = veclib.shuffle(all_f);

all_T = linspace(BurstPeriodRange(1),BurstPeriodRange(2),NPerCategory);
all_T = veclib.shuffle(all_T);

for i = 1:NPerCategory
	% PD spiking, LP bursting
	this_PD = synthetic.spiking(all_f(i),BinSize,SpiketimeJitter);

	
	this_LP = synthetic.bursting(all_T(i),NSpikesPerBurst,DutyCycle,SpiketimeJitter,BinSize);

	% add
	PD(1:length(this_PD),i+2*NPerCategory) = this_PD;
	LP(1:length(this_LP),i+2*NPerCategory) = this_LP;

end
experiment_idx(NPerCategory*2+1:NPerCategory*3) = categories(3);

assert(min(PD(:)) >=0,'FATAL:Negative spiketimes')
assert(min(LP(:)) >=0,'FATAL:Negative spiketimes')

% ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ 
% now we make the irregular/bursting state 


all_f = linspace(SpikingRateRange(1),SpikingRateRange(2),NPerCategory);
all_f = veclib.shuffle(all_f);

all_T = linspace(BurstPeriodRange(1),BurstPeriodRange(2),NPerCategory);
all_T = veclib.shuffle(all_T);

for i = 1:NPerCategory
	% PD bursting, LP irregular


	this_PD = synthetic.bursting(all_T(i),NSpikesPerBurst,DutyCycle,SpiketimeJitter,BinSize);
	this_LP = synthetic.irregular(all_f(i),BinSize);

	% add
	PD(1:length(this_PD),i+3*NPerCategory) = this_PD;
	LP(1:length(this_LP),i+3*NPerCategory) = this_LP;

end
experiment_idx(NPerCategory*3+1:NPerCategory*4) = categories(4);
assert(min(PD(:)) >=0,'FATAL:Negative spiketimes')
assert(min(LP(:)) >=0,'FATAL:Negative spiketimes')


% ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ 
% now we make the irregular/spiking state 


all_f = linspace(SpikingRateRange(1),SpikingRateRange(2),NPerCategory);
all_f = veclib.shuffle(all_f);
all_f2 = veclib.shuffle(all_f);


for i = 1:NPerCategory
	% PD irregular, LP spiking

	this_PD = synthetic.irregular(all_f(i),BinSize);
	this_LP = synthetic.spiking(all_f2(i),BinSize,SpiketimeJitter);;


	% add
	PD(1:length(this_PD),i+4*NPerCategory) = this_PD;
	LP(1:length(this_LP),i+4*NPerCategory) = this_LP;

end
experiment_idx(NPerCategory*4+1:NPerCategory*5) = categories(5);

assert(min(PD(:)) >=0,'FATAL:Negative spiketimes')
assert(min(LP(:)) >=0,'FATAL:Negative spiketimes')

% ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ 
% now we make the irregular state 

all_f = linspace(SpikingRateRange(1),SpikingRateRange(2),NPerCategory);
all_f = veclib.shuffle(all_f);
all_f2 = veclib.shuffle(all_f);


for i = 1:NPerCategory
	% PD irregular, LP spiking

	this_PD = synthetic.irregular(all_f(i),BinSize);
	this_LP = synthetic.irregular(all_f2(i),BinSize);


	% add
	PD(1:length(this_PD),i+5*NPerCategory) = this_PD;
	LP(1:length(this_LP),i+5*NPerCategory) = this_LP;

end
experiment_idx(NPerCategory*5+1:NPerCategory*6) = categories(6);

assert(min(PD(:)) >=0,'FATAL:Negative spiketimes')
assert(min(LP(:)) >=0,'FATAL:Negative spiketimes')

% ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ 
% now we make the irregular/silent state 

all_f = linspace(SpikingRateRange(1),SpikingRateRange(2),NPerCategory);
all_f = veclib.shuffle(all_f);

for i = 1:NPerCategory
	% PD irregular, LP silent
	this_PD = synthetic.irregular(all_f(i),BinSize);

	% add
	PD(1:length(this_PD),i+6*NPerCategory) = this_PD;


end
experiment_idx(NPerCategory*6+1:NPerCategory*7) = categories(7);
assert(min(PD(:)) >=0,'FATAL:Negative spiketimes')
assert(min(LP(:)) >=0,'FATAL:Negative spiketimes')


% ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ 
% now we make the bursting/silent state 


all_T = linspace(BurstPeriodRange(1),BurstPeriodRange(2),NPerCategory);
all_T = veclib.shuffle(all_T);

for i = 1:NPerCategory
	% PD bursting, LP silent


	this_PD = synthetic.bursting(all_T(i),NSpikesPerBurst,DutyCycle,SpiketimeJitter,BinSize);

	% add
	PD(1:length(this_PD),i+7*NPerCategory) = this_PD;

end
experiment_idx(NPerCategory*7+1:NPerCategory*8) = categories(8);

if min(PD(:)) < 0
	keyboard
end

% ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~ 
% now we make the phase_shifted case


all_PhaseOffsets = setdiff(PhaseOffsets,DefaultPhaseOffset);

all_T = linspace(BurstPeriodRange(1),BurstPeriodRange(2),NPerCategory);
all_T = veclib.shuffle(all_T);

for i = 1:NPerCategory
	% normal...with a random phase offset

	this_PD = synthetic.bursting(all_T(i),NSpikesPerBurst,DutyCycle,SpiketimeJitter,BinSize);
	this_LP = synthetic.bursting(all_T(i),NSpikesPerBurst,DutyCycle,SpiketimeJitter,BinSize);

	% introduce the phase shift 
	idx = randi(length(all_PhaseOffsets));
	this_LP = this_LP + all_PhaseOffsets(idx)*all_T(i);

	this_LP(this_LP>BinSize) = [];
	this_PD(this_PD>BinSize) = [];


	% add to data
	PD(1:length(this_PD),i+8*NPerCategory) = this_PD;
	LP(1:length(this_LP),i+8*NPerCategory) = this_LP;

end
experiment_idx(NPerCategory*8+1:NPerCategory*9) = categories(9);


if min(PD(:)) < 0
	keyboard
end




% package


data.PD = PD;
data.LP = LP;



data.experiment_idx = experiment_idx;
