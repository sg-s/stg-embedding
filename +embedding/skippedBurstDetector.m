

function NSpikeRatio = skippedBurstDetector(A,B)

isis = diff(A);

[~,idx] = sort(isis,'descend','MissingPlacement','last');

N1 = sum(B>A(idx(1)) & B<A(idx(1)+1));
N2 = sum(B>A(idx(2)) & B<A(idx(2)+1));

if N2 == 0
	NSpikeRatio = -1;
	return
end

NSpikeRatio = N1/N2;
