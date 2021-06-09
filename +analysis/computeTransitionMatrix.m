% given an (ordered) list of states, measure transition matrix
% and return that 
function [J, J_raw, marginal_counts] = computeTransitionMatrix(idx, time)

arguments
	idx (:,1) categorical
	time (:,1) double
end

validation.categoricalTime(idx,time);

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

% report # of transitions
disp(['There are ' mat2str(sum(J(:))) ' transitions here'])

% normalize
for i = 1:N
	if sum(J(i,:)) == 0
		continue
	end
	J(i,:) = J(i,:)./sum(J(i,:));
end

