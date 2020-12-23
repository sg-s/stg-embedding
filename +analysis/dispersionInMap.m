% function that estimates how spread out/clumpy
% points are in the map
% high values indicate many different clusters
% and/or widely distributed points
% low values mean all points are in one region
% and that region contains mostly points in that class

function [D, BinCenters, N, D_shuffled] = dispersionInMap(data, values, BinEdges, R)

arguments
	data (1,1) embedding.DataStore
	values (:,1) double
	BinEdges (:,1) double
	R (:,2) double
end


validation.firstDimensionEqualSize(values,data.mask);

% dispersion matrix using triangulation
BinCenters = BinEdges(1:end-1) + diff(BinEdges)/2;
D = NaN(length(BinCenters),100);
N = NaN*BinCenters;

D_shuffled = D;

for i = 1:length(BinCenters)

	this = values >= BinEdges(i) & values <= BinEdges(i+1);
	RR = (R(this,:));
	RR = RR - mean(RR);


	
	for j = 1:100
		D(i,j) = mean(std(datasample(RR,100)));
	end


	% shuffle and randomly sample
	
	for j = 1:100

		RR = datasample(R,sum(this));
		D_shuffled(i,j) = mean(std(datasample(RR,100)));

	end

end
