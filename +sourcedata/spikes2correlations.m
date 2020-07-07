% uses the autocorrelation function
% to convert spike trains into
% metrics that we can embed

function M = spikes2correlations(alldata)


BinSize = .01; % 10 ms

neurons = {'PD','LP'};

DataSize = length(alldata.mask);

M = struct;

for i = 1:length(neurons)

	X = zeros(DataSize,2e3);

	for j = 1:DataSize

		N = alldata.(neurons{i})(j,:);
		N = round(N/BinSize);
		N = N - min(N);

		X(j,N(N>0 & ~isnan(N))) = 1;
	end

	% convolve with Gaussian
	G = normpdf(-3:.3:3);
	for j = 1:DataSize
		X(j,:) = filtfilt(G,1,X(j,:));
	end


	TimeFirstZeroCrossing = NaN(DataSize,1);
	TimeFirstPeak = NaN(DataSize,1);
	HeightFirstPeak = NaN(DataSize,1);
	WidthFirstPeak = NaN(DataSize,1);


	parfor j = 1:DataSize

		if sum(X(j,:)) == 0 % no spikes
			continue
		end

		[acf,lags,bounds]=autocorr(X(j,:),500);
		
		temp = find(acf<0,1,'first');
		if isempty(temp)
			continue
		end

		TimeFirstZeroCrossing(j) = temp;
		d=(diff(acf>0));
		[~,a] = min(acf);

		if isempty(a)
			continue
		end

		z = find(d(a:end)==-1,1,'first')+a;
		if isempty(z)
			continue
		end

		[HeightFirstPeak(j),idx]=max(acf(a:z));
		TimeFirstPeak(j) = a+idx;

		WidthFirstPeak(j) = z-a;


	end



	M(i).TimeFirstPeak = TimeFirstPeak;
	%M(i).HeightFirstPeak = HeightFirstPeak;
	M(i).WidthFirstPeak = WidthFirstPeak;
	M(i).TimeFirstZeroCrossing = TimeFirstZeroCrossing./TimeFirstPeak;
	%M(i).NumSpikes = sum(X,2);
	%M(i).DutyCycle = max(alldata.([neurons{i} '_' neurons{i}]),[],2)./TimeFirstPeak;


end



[p, VectorisedPercentiles] = sourcedata.spikes2percentiles(alldata,'ISIorders',[1 2]);


M = [struct2array(M(1))/100 struct2array(M(2))/100 VectorisedPercentiles];

M(isnan(M)) = -10;
M(isinf(M)) = -10;
