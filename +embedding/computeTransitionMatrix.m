% given an (ordered) list of states, measure transition matrix
% and return that 
function J = computeTransitionMatrix(idx, time)

validation.categoricalTime(idx,time);

cats = categories(idx);





% find the break points
breakpts = [0; find((diff(time)) ~= 20)];

N = length(cats);
J = zeros(N);


for bi = 1:length(breakpts)-1


	this_idx = idx(breakpts(bi)+1:breakpts(bi+1));
	idx2 = circshift(this_idx,1);
	
	for i = 1:N
	    for j = 1:N
	        if i == j
	            continue
	        end

	        if sum(this_idx == cats(i)) == 0
				continue
			end

			J(i,j) = J(i,j) + sum((this_idx == cats(i)).*(idx2 == cats(j)));



			if J(i,j) == 0
				continue
			end

		end

	end

end







