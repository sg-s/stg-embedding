% thjis function helps us determine if 
% certain transition rates in the transition matrix
% are higher or lower than we would expect
% given the distribution of states

function P = estimateTransitionNullMatrix(idx, time)

arguments
	idx (:,1) categorical
	time (:,1) double
end

validation.categoricalTime(idx,time);


cats = categories(idx);
N = length(cats);

idx = double(idx);

P = zeros(N,N);

% estimate p(a->b) as p(b)/(p(b) + p(c) + ...)
% for each preparation 


for a = 1:N
	for b = 1:N
		if a == b
			continue
		end

		P(a,b) = mean(idx==a)/(1 - mean(idx==b));

	end
	P(a,:) =  P(a,:)./sum(P(a,:));
end




