% this function wrapper
% allows you to run a boostrap on any function
% with the function signature
% X = foo(A,B,C,...)
% by resampling from experiments and feeding 
% that to foo. 

function X = boostrapExperiments(foo, args, exp_idx, N)

arguments
	foo (1,1) function_handle
	args cell
	exp_idx (:,1) categorical
	N (1,1) double = 100
end

% first run it once to figure out what
% the output of foo looks like
X = foo(args{:});

X = zeros(size(X,1),size(X,2),N);


unique_preps = unique(exp_idx);
M = length(unique_preps);
for i = 1:N
	% resample preps
	these_preps = datasample(unique_preps,M);
	this = ismember(exp_idx,these_preps);
	these_args = args;
	for j = 1:length(these_args)
		these_args{j} = these_args{j}(this);
	end
	X(:,:,i) = foo(these_args{:});
end