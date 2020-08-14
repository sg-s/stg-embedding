% replace NaN in a vector with the largest
% non-NaN value
% useful for filling in "holes" in a dataset

function X = replaceNaNWith(X,W)

assert(isvector(X),'Expected X to be a vector')
assert(any(~isnan(X)),'No non-NaN values found')

X(isinf(X)) = NaN;

if isa(W,'function_handle')
	X(isnan(X)) = W(X);
else
	X(isnan(X)) = W;
end