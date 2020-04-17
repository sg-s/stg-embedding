function idx = makeCategoricalArray(N)

idx = categorical(NaN(N,1));

idx(1) = 'normal';
idx(1) = 'slow-bursting';
idx(1) = 'sparse-irregular';
idx(1) = 'LP-silent';
idx(1) = 'LP-silent-PD-bursting';
idx(1) = 'PD-silent';
idx(1) = 'PD-silent-LP-bursting';
idx(1) = 'weak-bursting';
idx(1) = 'PD-spikes-with-LP';
idx(1) = 'LP-weak-skipped';
idx(1) = 'PD-weak-skipped';
idx(1) = 'PD-skipped-bursting';
idx(1) = 'LP-skipped-bursting';
idx(1) = 'irregular-bursting';
idx(1) = 'irregular';
idx(1) = 'sparse-irregular';
idx(1) = 'silent';
idx(1) = 'LP-extended';
idx(1) = 'PD-extended';
idx(1) = 'LP-tonic';
idx(1) = 'PD-tonic';

idx(:) = categorical(NaN);