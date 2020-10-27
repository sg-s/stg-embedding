% computes a burstiness score, which
% is basically the biggest gap in sorted ISIs

function B = burstiness(data)

arguments
	data (1,1) embedding.DataStore
end

N = length(data.mask);

% compute burstiness from ISIs
PD_burst = NaN(N,1);
LP_burst = NaN(N,1);

for i = 1:N
	PD = sort(data.PD_PD(i,:));
	[isi_gap,pos] = max(diff(PD));
	PD_burst(i) = isi_gap/PD(pos);

	LP = sort(data.LP_LP(i,:));
	[isi_gap,pos] = max(diff(LP));
	LP_burst(i) = isi_gap/LP(pos);
end

% cut off
MaxValue = 10;
PD_burst(PD_burst>MaxValue) = MaxValue;
LP_burst(LP_burst>MaxValue) = MaxValue;

B = [PD_burst, LP_burst];

B(isnan(B)) = 0;