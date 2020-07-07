% converts isis to dominant period
% in a parameter-free manner

function T = ISI2DominantPeriod(isis)

T = NaN(size(isis,1),1);

time = linspace(0,20,2e3);


parfor i = 1:length(T)


	this_isis = isis(i,~isnan(isis(i,:)));
	this_isis(this_isis==0) = [];


	if length(this_isis) < 2
		% no ISIs -> no spikes
		T(i) = -10;
		continue
	end

	spikes = cumsum(this_isis);

	Y = interp1(spikes,this_isis,time);

	if sum(~isnan(Y)) < 501
		T(i) = -8;
		continue
	end

	acf = autocorr(Y,500); % 5 seconds

	FirstZeroCrossing = find(acf<0,1,'first');

	if isempty(FirstZeroCrossing)
		T(i) = -6;
		continue
	end

	SecondZeroCrossing = find(acf(FirstZeroCrossing+1:end)>0,1,'first') + FirstZeroCrossing;

	if isempty(SecondZeroCrossing)
		T(i) = -4;
		continue
	end

	ThirdZeroCrossing = find(acf(SecondZeroCrossing+1:end)<0,1,'first') + SecondZeroCrossing;

	if isempty(ThirdZeroCrossing)
		T(i) = -2;
		continue
	end

	[~,idx]=max(acf(SecondZeroCrossing:ThirdZeroCrossing));
	T(i) = idx + SecondZeroCrossing - 1;

end

T = T/100; % in seconds