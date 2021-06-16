% given an (ordered) list of states, measure transition matrix
% and return that 
function [J, J_raw, marginal_counts, J0] = computeTransitionMatrix(idx, time)

arguments
	idx (:,1) categorical
	time (:,1) double
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
J0 = 0*J;
P_before = sum(J_raw,2);
P_after = sum(J_raw);

P_before = P_before/sum(P_before);
P_after = P_after/sum(P_after);

for i = 1:N
	for j = 1:N
		if i == j
			continue
		end
		J0(i,j) = P_before(i)*P_after(j);
	end
end

for i = 1:N
	if sum(J0(i,:)) == 0
		continue
	end
	J0(i,:) = J0(i,:)./sum(J0(i,:));
end
