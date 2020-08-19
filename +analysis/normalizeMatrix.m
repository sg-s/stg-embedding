% normalize a matrix by a particular part of the matrix
% useful for normalizing a bunch of time series

function X = normalizeMatrix(X, NormWindow)

assert(isa(X,'double'),'Expected X to be a double matrix')
assert(ismatrix(X),'Expected X to be a matrix')

assert(isvector(NormWindow),'Expected NormWindow to be a vector')
assert(islogical(NormWindow),'Expected NormWindow to be a logical vector')

assert(size(X,2)==length(NormWindow),'Size of NormWindow should be the same as the 2nd dimension of X')


M = nanmean(X(:,NormWindow),2);
M = repmat(M,1,size(X,2));
X = X./M;
X(isinf(X)) = NaN;