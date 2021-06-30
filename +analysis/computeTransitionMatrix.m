% given an (ordered) list of states, measure transition matrix
% and return that 
function [J, J_raw, marginal_counts, p_below, p_above] = computeTransitionMatrix(idx, time, options)

arguments
	idx (:,1) categorical
	time (:,1) double
	options.N_bootstrap (1,1) double = 1e3
	options.Alpha (1,1) double = .05
end

validation.categoricalTime(idx,time);
validation.firstDimensionEqualSize(idx,time);

cats = categories(idx);

% convert states vector to int for faster processing
idx_int = double(idx);

% find the break points
breakpts = (diff(time)) ~= 20;

N = length(cats);
J = zeros(N);

marginal_counts = zeros(N,1);

for i = 1:length(idx)-1
	if breakpts(i)
		continue
	end

	J(idx_int(i),idx_int(i+1)) = J(idx_int(i),idx_int(i+1)) +1;
	marginal_counts(idx_int(i)) = marginal_counts(idx_int(i)) + 1;
end


J = J - J.*eye(N);

J_raw = J;

disp([mat2str(sum(J(:)>0)) ' distinct transitions'])

% report # of transitions
%disp(['There are ' mat2str(sum(J(:))) ' transitions here'])

% normalize
for i = 1:N
	if sum(J(i,:)) == 0
		continue
	end
	J(i,:) = J(i,:)./sum(J(i,:));
end


% estimate null matrix by considering independent transitions
P_before = sum(J_raw,2); % counts of states when they are before the transition P(x | x-> anything)
P_after = sum(J_raw); % P(x | anything -> x)

P_before = P_before/sum(P_before);
P_after = P_after/sum(P_after);


p_below = zeros(N);
p_above = zeros(N);

for i = 1:N

	W = P_after;
	W(i) = 0;

	n_transitions = sum(J_raw(i,:));

	this_row_bootstrap = zeros(N,options.N_bootstrap);

	for j = 1:options.N_bootstrap
		% pick n_transitions random states to end up in
		this = randsample(12,n_transitions,true,W);
		this_row_bootstrap(:,j) = histcounts(this,N);

	end

	data_less_than_boostrap = mean(J_raw(i,:)' < (this_row_bootstrap),2);
	data_more_than_boostrap = mean(J_raw(i,:)' > (this_row_bootstrap),2);

	data_less_than_boostrap(P_after == 0) = 0;
	data_more_than_boostrap(P_after == 0) = 0;

	p_below(i,:) = data_less_than_boostrap > (1-options.Alpha);
	p_above(i,:) = data_more_than_boostrap > (1-options.Alpha);



end


% zero out diagonal
p_below = p_below - eye(N).*p_below;
p_above = p_above - eye(N).*p_above;

% for i = 1:N
% 	for j = 1:N
% 		if i == j
% 			continue
% 		end
% 		J0(i,j) = P_before(i)*P_after(j);
% 	end
% end

% for i = 1:N
% 	if sum(J0(i,:)) == 0
% 		continue
% 	end
% 	J0(i,:) = J0(i,:)./sum(J0(i,:));
% end
