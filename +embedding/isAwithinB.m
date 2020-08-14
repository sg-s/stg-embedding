% given two spike trains A and B,
% checks if any spike in A is surrounded on both sides
% by B (and not A)

function TF = isAwithinB(A,B)

TF = 0;

for j = 2:length(A)-1

	if isnan(A(j+1))
		return
	end

	prev_A = A(j-1);
	next_A = A(j+1);
	prev_B = B(find(B<A(j),1,'last'));
	next_B = B(find(B>A(j),1,'first'));

	if isempty(next_B)
		return
	end
	if isempty(prev_B)
		continue
	end
	if prev_A > prev_B 
		continue
	end

	if next_A > next_B
		TF = 1;
		return
	end		
end