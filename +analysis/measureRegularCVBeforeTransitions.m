function [CV, CV0] = measureRegularCVBeforeTransitions(data, metrics, only_when,options)

arguments
	data (1,1) embedding.DataStore
	metrics (1,1) struct
	only_when (:,1) logical
	options.t_before (1,1) double = 10
	options.things_to_measure = {'PD_burst_period','LP_burst_period','PD_duty_cycle','LP_duty_cycle'};
end


things_to_measure = options.things_to_measure;
t_before = options.t_before;


unique_preps = unique(data.experiment_idx(only_when));
N = length(unique_preps);

CV = struct;
CV0 = struct;
for i = 1:length(things_to_measure)
	CV.(things_to_measure{i}) = NaN(N,t_before);
	CV0.(things_to_measure{i}) = NaN(N,1);
end


for i = 1:N
	this = data.experiment_idx == unique_preps(i) & only_when;
	idx = data.idx(this);
	r = idx == 'regular';

	this_CV = struct;
	for j = 1:length(things_to_measure)
		thing = things_to_measure{j};
		this_CV.(thing) = metrics.([thing '_std'])(this)./metrics.(thing)(this);
	end


	% find transitions from normal
	transitions = [(diff(r) == -1); 0];
	time = veclib.timeToNextEvent(transitions);

	

	for k = 1:length(things_to_measure)
		thing = things_to_measure{k};

		for j = 1:t_before
			CV.(thing)(i,j) = nanmean(this_CV.(thing)(time == j-1 & idx == 'regular'));
		end
		CV0.(thing)(i) = nanmean(this_CV.(thing)(time > t_before & idx == 'regular'));
	end


end