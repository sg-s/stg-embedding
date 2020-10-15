% estimates the quality of embedding
% given some labels (which we assume to be ground truth)

function quality(R, idx)

arguments

	R (:,2) double
	idx (:,1) categorical

end

% find the closest points from all points
closest = NaN(length(R),1);

parfor i = 1:length(R)
	D = pdist2(R(i,:),R);
	D(i) = Inf;
	[~,closest(i)] = min(D);
end

closest_in_same_group = idx(closest) == idx;
closest_in_same_group(isundefined(idx)) = true;


measure_these = {'normal','LP-weak-skipped','PD-weak-skipped','interrupted-bursting','aberrant-spikes'};


fprintf('\n\n')
disp('Group           Clustering score')
disp('--------------------------------')
for i = 1:length(measure_these)
	S = round(nanmean(closest_in_same_group(idx==measure_these{i}))*100);
	disp([strlib.fix(measure_these{i},22) '  ' mat2str(S)])
end
