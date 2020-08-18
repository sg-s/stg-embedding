function idx =  readAnnotations(MasterIdx, Hashes, RawData, idx)


% hash the data
raw_data_hashes = cell(length(idx),1);
parfor i = 1:length(idx)
	raw_data_hashes{i} = hashlib.md5hash(RawData(i,:));
end

[hash_exists,loc] = ismember(raw_data_hashes,Hashes);

idx(hash_exists) = MasterIdx(nonzeros(loc));
