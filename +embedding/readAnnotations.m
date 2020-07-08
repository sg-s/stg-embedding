function idx =  readAnnotations(MasterIdx, Hashes, RawData, idx)

parfor i = 1:length(idx)
	this_hash = hashlib.md5hash(RawData(i,:));
	loc = find(strcmp(this_hash,Hashes));
	if ~isempty(loc)
		loc = loc(1);
		idx(i) = MasterIdx(loc);
	end
end
