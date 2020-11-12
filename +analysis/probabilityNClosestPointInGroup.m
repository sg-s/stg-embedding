% computes distance of each point to other points
% for some subset of the data

function P = probabilityNClosestPointInGroup(R,these_points)

arguments
	R (:,2) double
	these_points (:,1) logical
end

validation.firstDimensionEqualSize(R,these_points);


P = NaN;

if ~any(these_points)
	return
end


X = R(these_points,:);



[D,I] =(pdist2(R,X,'euclidean','Smallest',length(X)));
I = I(:);
these_points = find(these_points);
P = mean(ismember(I,these_points));