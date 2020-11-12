function plotSortedCDF(X, varargin)

arguments 
	X (:,1) double
end

arguments (Repeating)
	varargin
end

X(isnan(X)) = [];
Y = linspace(0,1,length(X));
plot(sort(X),Y, varargin{:});

