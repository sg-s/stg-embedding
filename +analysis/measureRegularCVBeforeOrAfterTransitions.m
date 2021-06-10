%% 
% This function measured the variability in some metric
% in regular states before a transition to some other state
% metrics are only measured in only_when


function [CV, CV0] = measureRegularCVBeforeOrAfterTransitions(data, metrics, only_when,options)

arguments
	data (1,1) embedding.DataStore
	metrics (1,1) struct
	only_when (:,1) logical
	options.T (1,1) double = 10
	options.BeforeOrAfter = 'Before'
	options.things_to_measure = {'PD_burst_period','LP_burst_period','PD_duty_cycle','LP_duty_cycle'};
end


assert(numel(data.idx) == numel(only_when),'data and only_when should have the same size')
assert(numel(data.idx) == numel(metrics.PD_burst_period),'data and metrics should have the same size')

things_to_measure = options.things_to_measure;
T = options.T;


unique_preps = unique(data.experiment_idx(only_when));
N = length(unique_preps);

CV = struct;
CV0 = struct;
for i = 1:length(things_to_measure)
	CV.(things_to_measure{i}) = NaN(N,T);
	CV0.(things_to_measure{i}) = NaN(N,1);
end


n_points = 0;


for i = 1:N
	this = data.experiment_idx == unique_preps(i) & only_when;


	this_CV = struct;
	for j = 1:length(things_to_measure)
		thing = things_to_measure{j};
		this_CV.(thing) = metrics.([thing '_std'])(this)./metrics.(thing)(this);
	end



	idx = data.idx(this);
	r = idx == 'regular';
	time_offset = data.time_offset(this);


	% we need to handle each time segment independently,
	% because there are no guarantees on what time_offset
	% looks like. 
	labels = veclib.labelSegments([20; diff(time_offset)] ~= 20);
	time = NaN*labels;

	for j = 1:labels(end)
		rr = r(labels == j);
		

		if strcmp(options.BeforeOrAfter,'Before')
			transitions = [(diff(rr) == -1); 0];
			time(labels==j) = veclib.timeToNextEvent(transitions);
			offset = 1;
		else
			transitions = [0; (diff(rr) == -1)];
			time(labels==j) = veclib.timeSinceLastEvent(transitions);
			offset = 0;
		end
	end

	if all(isnan(time))
		continue
	end

	for k = 1:length(things_to_measure)
		thing = things_to_measure{k};


		for j = 1:T
			temp = this_CV.(thing)(time == j-offset & idx == 'regular');
			if k == 1
				n_points = n_points + sum(~isnan(temp));
			end

			CV.(thing)(i,j) = nanmean(temp);
		end
		CV0.(thing)(i) = nanmean(this_CV.(thing)(time > T & idx == 'regular'));
	end


end


% report n_points and n_animals
disp(['n_points = ' mat2str(n_points)]);
disp(['n_animals = ' mat2str(N)])