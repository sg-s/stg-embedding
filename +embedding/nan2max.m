% replace NaN in a vector with the largest
% non-NaN value
% useful for filling in "holes" in a dataset

function X = nan2max(X)

assert(isvector(X),'Expected X to be a vector')
assert(any(~isnan(X)),'No non-NaN values found')

X(isinf(X)) = NaN;
X(isnan(X)) = nanmax(X);