function D = EarthMoverDistance2(A,W)


D = zeros(1e4,1e4);


for i = 1:1e4
	if rem(i,1e2) == 0
		disp(i)
	end
	for j = (i+1):1e4
		if all(isnan(A(i,:))) & all(isnan(A(j,:)))
			% both empty
			D(i,j) = D(i,j)  + sum(W);
		elseif all(isnan(A(i,:)))
			% only one empty
			D(i,j) = D(i,j) + sum(A(j,:)*W');
		elseif all(isnan(A(j,:)))
			% only one empty
			D(i,j) = D(i,j) + sum(A(i,:)*W');
		else
			% good
			D(i,j) = D(i,j) + emd(A(i,:),A(j,:),W,W);
		end
	end
end
