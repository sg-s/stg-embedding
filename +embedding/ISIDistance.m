% computes the distance between two ISI sets
% this version of the distance function works
% as follows:
% it first computes histograms
% and binarizes the histograms
% distances between two binarized histogram
% are defined as the sum of distances of every
% non-zero bin to every other non-zero bin

function D = ISIDistance(ISI, BinEdges)

arguments
	ISI (:,1e3) double
	BinEdges (:,1) double = [logspace(-2,.5,29) 20];
end


N = size(ISI,1);
SZ = length(BinEdges);

% compute histogram counts and binarize 
H = zeros(N,length(BinEdges)-1);
for i = 1:N
	H(i,:) = histcounts(ISI(i,:),BinEdges);
end
H(H>0) = 1;


% make sure all histograms are nonzero somewhere
H(sum(H,2) == 0,end) = 1;


D = zeros(N);
parfor i = 1:N
	D(i,:) = embedding.parallelBinaryDistance(H,i);
end

D = D + D';