% saves the data that we annotate so we can reuse this later


function save()

m = evalin('base','m');

if exist('m','var') && isa(m,'clusterlib.manual') 
else
	error('Cannot save ... no clusterlib.manual object')
end

	

try
	load('../annotations/labels.cache','H','idx','-mat')
	H = H(:);
catch
	H = {};
	idx = categorical(NaN);
end


% hash the raw data in parallel
raw_data_hashes = cell(size(m.RawData,1),1);
tic
for i = 1:length(raw_data_hashes)
	raw_data_hashes{i} = hashlib.md5hash(m.RawData(i,:));
end
toc



% find hashes in raw data that are not in H
new_hashes = setdiff(raw_data_hashes,H);

% add the new hashes to the hash table
% and make placeholders for them
if ~isempty(new_hashes)
	H = [H; new_hashes];
	idx = [idx; repmat(categorical(NaN),length(new_hashes),1)];
end

assert(length(idx)==length(H),'fatal length mismatch')


[~,locs]=ismember(raw_data_hashes,H);
idx(locs) = m.idx;

assert(length(idx)==length(H),'fatal length mismatch')


save('../annotations/labels.cache','H','idx')

disp('DONE!')


