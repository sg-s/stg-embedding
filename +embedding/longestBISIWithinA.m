

function X = longestBISIWithinA(A,B)

X = 0*A;

for i = 1:length(A)-1

	if isnan(A(i+1))
		break
	end

	isis = max(diff(B(B>A(i) & B < A(i+1))));

	if isempty(isis)
		continue
	end

	X(i) = isis;

end

X = sort(X,'descend','MissingPlacement','last');

X = X(1)/X(2);