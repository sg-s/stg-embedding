function M = findMaxISIInOtherNeuron(A,B)

M = NaN*A;

for i = 1:length(A)-1
	if isnan(A(i+1))
		break
	end

	temp = max(diff(B(B>A(i) & B < A(i+1))));
	if isempty(temp)
		continue
	end

	M(i) = temp;

end

M = nanmax(M);