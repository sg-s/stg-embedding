

function D = distanceBetweenSubsequentPts(alldata, R, offset)

arguments
	alldata (1,1) embedding.DataStore
	R (:,2)
	offset (1,1) double = 1
end

R2 = circshift(R,offset);
D = sqrt((R2(:,1) - R(:,1)).^2 + (R2(:,2) - R(:,2)).^2);

% censor pts when experiment switches
D(1) = NaN;
experiment_idx = alldata.experiment_idx;
parfor i = 2:length(D)
	if experiment_idx(i) ~= experiment_idx(i-1)
		D(i) = NaN;
	end
end