% this function compares two categorical distributions
% A and B
% the variables A and B are expected to be the counts
% in each category, and should be of equal length
% the analysis is based on 
% https://www3.nd.edu/~rwilliam/stats1/x51.pdf

function H0rejected = compareCategoricalDistributions(A,B, Alpha)

arguments
	A (:,1) double
	B (:,1) double
	Alpha (1,1)  double = .05
end

validation.firstDimensionEqualSize(A,B);

% estimate null model probabilities
P0 = A/sum(A);


% estimate expected frequency for test data
N = sum(B);
E = N*P0;


% compute chi-squared
chi2 = ((B-E).^2)./E;
chi2(isnan(chi2)) = 0;


x = linspace(0,100,1e3);
y = chi2cdf(x,length(A)-1);

critical_value = x(find(y>(1-Alpha),1,'first'));

if sum(chi2) <= critical_value
	H0rejected = false;
else
	H0rejected = true;
end