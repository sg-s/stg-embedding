% saves the data that we annotate so we can reuse this later


function save()

m = evalin('base','m');

if exist('m','var') && isa(m,'clusterlib.manual') 
else
	error('Cannot save ... no clusterlib.manual object')
end


F = parfeval(@saveBG,0,m.RawData,m.idx);

function saveBG(RawData,midx)



	

	try
		load('../annotations/labels.cache','H','idx','-mat')
	catch
		H = {};
		idx = categorical(NaN);
	end
	

	% hash the raw data
	for i = 1:size(RawData,1)
		this_hash = hashlib.md5hash(RawData(i,:));
		loc = find(strcmp(this_hash,H));
		if isempty(loc)
			H = [H this_hash];
			idx = [idx; midx(i)];
		else
			idx(loc) = midx(i);
		end
	end

	save('../annotations/labels.cache','H','idx')

	disp('DONE!')



end



end