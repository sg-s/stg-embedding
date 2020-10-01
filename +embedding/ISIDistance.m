% computes the distance between two ISI sets
% 
function D = ISIDistance(A, BinEdges)

arguments
	A (:,1e3) double
	BinEdges (:,1) double = logspace(-2,1,30);
end


N = size(A,1);
SZ = length(BinEdges);

% compute histogram counts and binarize 
H = zeros(N,length(BinEdges)-1);
for i = 1:N
	H(i,:) = histcounts(A(i,:),BinEdges);
end
H(H>0) = 1;


% make sure all histograms are nonzero somewhere
H(sum(H,2) == 0,end) = 1;


D = zeros(N);
parfor i = 1:N
	D(i,:) = embedding.parallelBinaryDistance(H,i);
end