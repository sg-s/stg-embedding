function dwell_times = dwellTimesInSegment(idx)

assert(isvector(idx),'Expected idx to be a vector')
assert(iscategorical(idx),'Expected idx to be categorical')

cats = categories(idx);

dwell_times = NaN(length(cats),1);

for i = 1:length(cats)

	[ons,offs]=veclib.computeOnsOffs(idx==cats{i});

	% don't forget the case where the first element is the thing we want
	if idx(1) == cats{i}
		ons = [1; ons(:)];
		offs = [find(idx ~= cats{i},1,'first')-1; offs(:)];
	end

	offs =  unique(offs);

	if length(offs) < length(ons)
		offs = [offs(:); length(idx)];
	end

	if(length(ons) ~= length(offs))
		keyboard
	end
	dwell_times(i) = mean(offs-ons);

end

dwell_times(dwell_times==0) = 1;