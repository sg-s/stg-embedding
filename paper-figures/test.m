



idx = moddata.idx(only_when);
time = moddata.time_offset(only_when);
exp_idx = moddata.experiment_idx(only_when);

% do the null model

% foo = @analysis.estimateTransitionNullMatrix;
% J0 = analysis.boostrapExperiments(foo,{idx,time},exp_idx);

J0 = analysis.estimateTransitionNullMatrix(idx,time);

% now measure the real J


foo = @analysis.computeTransitionMatrix;
J = analysis.boostrapExperiments(foo,{idx,time},exp_idx);

p_val = zeros(12);

for i = 1:12
	for j = 1:12
		if i == j
			continue
		end

		x = squeeze(J(i,j,:));
		y = squeeze(J0(i,j,:));

		[~,p_val(i,j)] = ttest2(x,y);
	end

end