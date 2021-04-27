% this function finds regions in the map
% that are enriched for some condition(s)
% the way it works is for each point,
% it finds the N closest neighbours, and for those
% measures the probability that those points are in
% condition(s) A, B..., etc.
% it then normalizes the fractional probs. over
% the entire dataset and returns that

function P = findRelativeAbundanceInMap(R, conditions, N_neighbours)


arguments
	R (:,2) double
	conditions logical
	N_neighbours (1,1) double = 50
end


P = double(conditions*0);


tic
parfor i = 1:length(R)

	[~,idx]=sort(sum(abs(R(i,:)-R),2));
	closest_pts = idx(1:N_neighbours);

	% measure probs each condition
	P(i,:) = sum(conditions(closest_pts,:));
end
toc
P = P/N_neighbours;