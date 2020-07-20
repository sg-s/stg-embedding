function alldata = getRecordingDate(alldata)

assert(isstruct(alldata),'Expected first argument to be the struct alldata')

all_exps = unique(alldata.experiment_idx);

alldata.date = NaN*alldata.mask;

for i = 1:length(all_exps)

	disp(all_exps(i))

	datafolder = crabsort.open(char(all_exps(i)),true);


	allfiles = dir(fullfile(datafolder.folder,'*.crab'));



	if length(allfiles) > 0


		m = matfile(fullfile(allfiles(1).folder,allfiles(1).name));
		if ~isempty(m.metadata)
			
			metadata = m.metadata;
			if ~isfield(metadata,'uFileStartDate')
				continue
			end

			disp(['Got some dates from a .crab file: ' mat2str(metadata.uFileStartDate)])
			alldata.date(alldata.experiment_idx == all_exps(i)) = metadata.uFileStartDate;

		end

		continue

	end


	% allfiles = dir(fullfile(datafolder.folder,'*.smr'));
	% if length(allfiles) > 1
	% 	keyboard

	% 	continue
	% end

	allfiles = dir(fullfile(datafolder.folder,'*.abf'));

	if length(allfiles) == 0
		continue
	end

	try
		[~,~,metadata]=filelib.abfload(fullfile(allfiles(1).folder,allfiles(1).name));
	catch
		continue
	end

	if ~isfield(metadata,'uFileStartDate')
		continue
	end

	alldata.date(alldata.experiment_idx == all_exps(i)) = metadata.uFileStartDate;
	disp(['Got some dates from a ABF file: ' mat2str(metadata.uFileStartDate)])

end