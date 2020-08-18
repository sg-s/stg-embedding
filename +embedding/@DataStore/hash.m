% returns hash of all values in the datastore object 

function raw_data_hashes = hash(alldata)

assert(length(alldata)==1,'Expected DataStore to be scalar')

raw_spike_data = [alldata.LP, alldata.PD];

raw_data_hashes = cell(size(raw_spike_data,1),1);

for i = 1:length(raw_data_hashes)
	raw_data_hashes{i} = hashlib.md5hash(raw_spike_data(i,:));
end

