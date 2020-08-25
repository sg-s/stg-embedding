% this function caches all experimental dates
% for the experiments defined in alldata
function cacheExperimentDates(alldata)


arguments
	alldata (1,1) embedding.DataStore
end


all_exps = unique(alldata.experiment_idx);
all_exps(isundefined(all_exps)) = [];


load('../cache/recording_dates.mat','ExpDates')



for i = 1:length(all_exps)

	if ismember(all_exps(i),[ExpDates.exp])
		continue
	end

	this_exp  = char(all_exps(i));
	if strcmp(this_exp(1:3),'140')
		continue
	end


	disp(all_exps(i))


	try
		temp = crabsort.open(char(all_exps(i)),true);
	catch
		continue
	end
	
	allfiles = dir(temp.folder);

	j = 1;
	for j = 1:length(allfiles)


		[~,~,ext]=fileparts(allfiles(j).name);

		if ~ismember(ext,{'.crab','.abf','.smr'})
			continue
		end

		if ~strcmp(allfiles(j).name(1),'.')
			break
		end
	end

	C = crabsort(false);
	C.path_name = allfiles(j).folder;
	C.file_name = allfiles(j).name;

	try
		C.loadFile;
	catch
		continue
	end
	

	if isstruct(C.metadata)
		if isfield(C.metadata,'uFileStartDate')
			this_date = datetime(mat2str(C.metadata.uFileStartDate),'InputFormat','yyyyMMdd');
			ExpDates = [ExpDates; struct('date',this_date,'exp',all_exps(i))];
		else
			keyboard
		end

	else
		keyboard
	end

	save('../cache/recording_dates.mat','ExpDates')

end

