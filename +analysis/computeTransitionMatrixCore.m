% core version of computeTransitionMatrix, 
% which is used internally to bootstrap statistics

function J = computeTransitionMatrixCore(idx, J)


arguments
	idx (:,1) double
	J double
end

for i = 1:length(idx)-1
	J(idx(i),idx(i+1)) = J(idx(i),idx(i+1)) + 1;
end