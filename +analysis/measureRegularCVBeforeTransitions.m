%% 
% This function measured the variability in some metric
% in regular states before a transition to some other state
% metrics are only measured in only_when


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
		transitions = [(diff(rr) == -1); 0];
		time(labels==j) = veclib.timeToNextEvent(transitions);
	end

	

	for k = 1:length(things_to_measure)
		thing = things_to_measure{k};

		for j = 1:t_before
			temp = this_CV.(thing)(time == j-1 & idx == 'regular');
			if k == 1
				n_points = n_points + sum(~isnan(temp));
			end
			CV.(thing)(i,j) = nanmean(temp);
		end
		CV0.(thing)(i) = nanmean(this_CV.(thing)(time > t_before & idx == 'regular'));
	end


end


% report n_points and n_animals
disp(['n_points = ' mat2str(n_points)]);
disp(['n_animals = ' mat2str(N)])