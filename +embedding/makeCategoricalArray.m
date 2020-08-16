function idx = makeCategoricalArray(N)

idx = categorical(NaN(N,1));


% baseline
idx(1) = 'normal';



% one neuron fucked up
idx(1) = 'LP-silent';
idx(1) = 'LP-silent-PD-bursting';
idx(1) = 'PD-silent';

idx(1) = 'LP-irregular-bursting'; % sometimes bursting,sometimes not. PD ok
idx(1) = 'aberrant-spikes';

idx(1) = 'LP-sparse';


% one neuron weak bursting
idx(1) = 'LP-skipped-bursts';
idx(1) = 'LP-weak-skipped';

idx(1) = 'PD-skipped-bursts';
idx(1) = 'PD-weak-skipped';


% both neurons weird
idx(1) = 'sparse-irregular';
idx(1) = 'LP-PD-01';
idx(1) = 'irregular';
idx(1) = 'silent';
idx(1) = 'interrupted-bursting';
idx(1) = 'irregular-bursting'; % always bursting, but irregularly (both neurons)


idx(1) = 'phase-disturbed';

idx(:) = categorical(NaN);