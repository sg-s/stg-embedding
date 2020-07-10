function idx = makeCategoricalArray(N)

idx = categorical(NaN(N,1));


% baseline
idx(1) = 'normal';



% one neuron fucked up
idx(1) = 'LP-tonic';
idx(1) = 'PD-tonic';
idx(1) = 'LP-var-burst';
idx(1) = 'PD-var-burst';
idx(1) = 'LP-silent';
idx(1) = 'LP-silent-PD-bursting';
idx(1) = 'PD-silent';
idx(1) = 'PD-silent-LP-bursting';
idx(1) = 'LP-02';
idx(1) = 'PD-02';
idx(1) = 'PD-skipped-bursting';
idx(1) = 'LP-skipped-bursting';
idx(1) = 'synchronous-spike'; % at least one PD,LP spike pair co-occur
idx(1) = 'LP-int-bursting'; % sometimes bursting,sometimes not. PD ok
idx(1) = 'PD-int-bursting';

% both neurons weird
idx(1) = 'slow-bursting';
idx(1) = 'sparse-irregular';
idx(1) = 'LP-PD-02';
idx(1) = 'var-burst';
idx(1) = 'irregular';
idx(1) = 'sparse-irregular';
idx(1) = 'silent';
idx(1) = 'interrupted-bursting';
idx(1) = 'LP-02-PD-var-burst';
idx(1) = 'irregular-bursting'; % always bursting, but irregularly (both neurons)


idx(:) = categorical(NaN);