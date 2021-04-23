% given an (ordered) list of states, measure transition matrix
% and return that 
function J = computeTransitionMatrix(idx, time)

arguments
	idx (:,1) categorical
	time (:,1) double
end

validation.categoricalTime(idx,time);

cats = categories(idx);

% convert states vector to int for faster processing
idx_int = double(idx);


% find the break points
breakpts = (diff(time)) ~= 20;

N = length(cats);
J = zeros(N);

for i = 1:length(idx)-1
	if breakpts(i)
		continue
	end

	J(idx_int(i),idx_int(i+1)) = J(idx_int(i),idx_int(i+1)) +1;
end




