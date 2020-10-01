function D = parallelBinaryDistance(H,row)

arguments
	H double
	row (1,1) double
end

N = size(H,1);
D = zeros(N,1);

for i = row+1:N
	D(i) = embedding.BinaryDistance(H(row,:),H(i,:));
end