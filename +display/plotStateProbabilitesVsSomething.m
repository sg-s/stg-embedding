
% assuming something is some discrete vector which is matched
% to elements of x 

function plotStateProbabilitesVsSomething(data, something, x)

arguments

	data (1,1) embedding.DataStore
	something (:,1) double 
	x (:,1) double

end

validation.firstDimensionEqualSize(something,data.mask);


all_preps = unique(data.experiment_idx);

% compute probabilities of states as a 

cats = categories(data.idx);
colors = display.colorscheme(cats);
state_probability = zeros(length(x),length(cats));


prep_counts = 0*x;

for i = 1:length(x)
	idx = data.idx(something==x(i));
	preps = data.experiment_idx(something==x(i));
	state_probability(i,:) = histcounts(idx,cats);
	state_probability(i,:) = state_probability(i,:)/sum(state_probability(i,:));
	prep_counts(i) = length(unique(preps));
end

% switching_rate = 0*x;
% switching_rate_N = 0*x;
% % find the switching rates by going prep by prep
% for i = 1:length(all_preps)
% 	use_this = data.experiment_idx == all_preps(i);
% 	idx = data.idx(use_this);
% 	this_x = something(use_this);

% 	for j = 1:length(x)-1
% 		prev_state = idx(this_x == x(j));
% 		next_state = idx(this_x == x(j+1));
% 		if isempty(prev_state) | isempty (next_state)
% 			continue
% 		end
% 		if isundefined(prev_state) | isundefined(next_state)
% 			continue
% 		end
% 		switching_rate_N(j) = switching_rate_N(j) + 1;

% 		if prev_state ~= next_state
% 			switching_rate(j) = switching_rate(j)+1;
% 		end
% 	end

% end
% switching_rate = switching_rate./switching_rate_N;


% smooth them a little bit
state_probability(isnan(state_probability)) = 0;
for i = 1:length(cats)
	state_probability(:,i) = filtfilt(ones(2,1),2,state_probability(:,i));
end



h = area(x,state_probability);
for i = 1:length(h)
	h(i).LineStyle = 'none';
	h(i).FaceColor = colors(cats{i});
end

set(gca,'XLim',[x(1) x(end)])