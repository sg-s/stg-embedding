% measures transition rates in two conditions A and B
% and bootstraps and shuffles data to estimate the p-value
% for differences in transition rates between the two
% conditions
% we assume A and B to be logical vectors that we can 
% use to index into data

function deltaJ_bootstrap = bootstrapTransitionRateDifferences(data, A, B, N)

arguments
	data (1,1) embedding.DataStore
	A (:,1) logical
	B (:,1) logical
	N (1,1) double = 1000
end


M = length(categories(data.idx));
deltaJ_bootstrap = NaN(M,M,N);

preps = unique(data.experiment_idx(A | B));
experiment_idx = data.experiment_idx;
idx0 = data.idx;
time0 = data.time_offset;

parfor i = 1:N

	AA = A;
	BB = B;

	% for each prep
	for j = 1:length(preps)

		if rand > .5
			% for this prep, flip the A and B
			makeA = experiment_idx == preps(j) & BB;
			makeB = experiment_idx == preps(j) & AA;

			BB(experiment_idx == preps(j) & BB) = false;
			AA(experiment_idx == preps(j) & AA) = false;

			BB(makeB) = true;
			AA(makeA) = true;

		end

	end

	idx = idx0(AA);
	time = time0(AA);
	JA = analysis.computeTransitionMatrix(idx,time);
	JA = JA/length(time)/20; % in seconds

	idx = idx0(BB);
	time = time0(BB);
	JB = analysis.computeTransitionMatrix(idx,time);
	JB = JB/length(time)/20; % in seconds

	deltaJ_bootstrap(:,:,i) = JB - JA;

end


