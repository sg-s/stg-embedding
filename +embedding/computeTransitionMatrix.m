% given an (ordered) list of states, measure transition matrix
% and return that 
function J = computeTransitionMatrix(idx)

assert(iscategorical(idx),'Argument must be a categorical array')
assert(isvector(idx),'Argument must be a vector')
idx = idx(:);


idx2 = circshift(idx,1);

labels = unique(idx);



N = length(labels);
J = zeros(N);

for i = 1:N
    for j = 1:N
        if i == j
            continue
        end

		J(i,j) = sum((idx == labels(i)).*(idx2 == labels(j)));
		% normalize
		J(i,j) = J(i,j)/sum(idx == labels(i));
	end

end