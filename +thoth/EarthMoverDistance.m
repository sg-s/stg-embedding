function D = EarthMoverDistance(A,W)

N = size(A,1);
D = zeros(N,N);

A(isnan(A)) = 0;

if nargin == 1
	parfor i = 1:N
		D(i,:) = sum(abs(A - A(i,:)),2);
	end

	return
end

W = W(:);
W = W';

assert(size(W,2) == size(A,2),'A and W sizes do not match')

parfor i = 1:N
	D(i,:) = sum(abs(A - A(i,:)).*W,2);
end

% return

% slow, non-vectorized code

% for i = 1:N
% 	if rem(i,1e2) == 0
% 		disp(i)
% 	end
% 	for j = (i+1):N
% 		if all(isnan(A(i,:))) & all(isnan(A(j,:)))
% 			% both empty
% 			% distance is zero
% 			% do nothing
% 		elseif all(isnan(A(i,:)))
% 			% only one empty
% 			D(i,j) = D(i,j) + sum(A(j,:));
% 		elseif all(isnan(A(j,:)))
% 			% only one empty
% 			D(i,j) = D(i,j) + sum(A(i,:));
% 		else
% 			% good
% 			D(i,j) = D(i,j) + sum(abs(A(i,:) - A(j,:)));
% 		end
% 	end
% end
