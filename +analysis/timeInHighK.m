function time_in_high_k =  timeInHighK(data)

arguments
	data (1,1) embedding.DataStore
end

all_preps = categories(data.experiment_idx);

time_in_high_k = NaN(length(data.mask),1);

for prep = List(all_preps)

	if max(data.Potassium(data.experiment_idx == prep)) == 1
		continue
	end

	thisdata = data.slice(data.experiment_idx == prep);

	

	a = find(thisdata.Potassium > 1,1,'first');
	z = find(thisdata.Potassium(a:end) == 1,1,'first') + a;

	time = thisdata.time_offset;
	time = time - time(a);
	time(z:end) = NaN;

	time_in_high_k(data.experiment_idx == prep) = time;

end