% shuffles all metrics and measures within prep
% and across prep CV to see if there is any 
% significant difference between the two
% this computation takes some time 
% so this will be cached

function [p_shuffled, within_prep_shuffled] = bootstrapMetrics(metrics,experiment_idx, fn, N)


arguments
	
	metrics (1,1) struct
	experiment_idx (:,1) categorical
	fn (:,1) cell = fieldnames(metrics)
	N (1,1) double = 1e3

end

hash = hashlib.md5hash([structlib.md5hash(metrics),
hashlib.md5hash([fn{:}]),
hashlib.md5hash(double(experiment_idx)),
hashlib.md5hash(N)]);

cacheloc = ['../cache/' hash '.mat'];

if exist(cacheloc,'file') == 2
	load(cacheloc,'p_shuffled','within_prep_shuffled');
	return
end

p_shuffled = struct;
within_prep_shuffled = NaN(length(fn),N);

for i = 1:length(fn)
	disp(fn{i})
	for j = N:-1:1
		[M,S] = analysis.averageBy(veclib.shuffle(metrics.(fn{i})),experiment_idx);
		within_prep_shuffled(i,j) = nanmean(S./M);
		p_shuffled(j).(fn{i}) = M;
	end
end


save(cacheloc,'p_shuffled','within_prep_shuffled');