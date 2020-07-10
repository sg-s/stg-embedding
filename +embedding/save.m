% saves the data that we annotate so we can reuse this later

if exist('m','var') && isa(m,'clusterlib.manual') 
else
	error('Cannot save ... no clusterlib.manual object')
end

try
	load('../annotations/labels.cache','H','idx','-mat')
catch
	H = {};
	idx = categorical(NaN);
end
RawData = m.RawData;


% hash the raw data
for i = 1:size(RawData,1)
	corelib.textbar(i,length(m.idx))
	this_hash = hashlib.md5hash(RawData(i,:));
	loc = find(strcmp(this_hash,H));
	if isempty(loc)
		H = [H this_hash];
		idx = [idx; m.idx(i)];
	else
		idx(loc) = m.idx(i);
	end
end

save('../annotations/labels.cache','H','idx')

clearvars RawData idx H