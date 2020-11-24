% searches all the data and returns all data
% in a vector of embedding.DataStore objects

function alldata = getAllData(UseCache)

arguments
    UseCache (1,1) logical = true
end

if exist('../cache/alldata.mat','file') & UseCache
    load('../cache/alldata.mat')
    return
end


filelib.mkdir(getpref('embedding','cache_loc'))



% get a list of all experiments in the crabsort spikes folder
spikesfolder = getpref('crabsort','store_spikes_here');
all_exps = dir(spikesfolder);

% purge junk
all_exps = all_exps([all_exps.isdir]);
all_exps(cellfun(@(x) strcmp(x(1),'.'),{all_exps.name})) = [];


% first check that everything is cached nicely
for i = 1:length(all_exps)


	if strcmp(all_exps(i).name(1),'.')
		continue
	end

    % debug
    % if str2double(all_exps(i).name(1:3)) ~= 897
    %     continue
    % end

	this_exp = all_exps(i).name;

    % get the consolidated data from crabsort
    % this is internally cached by crabsort so
    % should chug along quickly 
    data = crabsort.consolidate(this_exp,'neurons',{'PD','LP'});

    % chunk into 20 s segments
    data = crabsort.analysis.chunk(data);


    assert(isfield(data,'experimenter'),'Experimenter not set!')

    % some metadata tweaks
    if any(data.experimenter(1) == 'cronin')
        data = metadata.cronin(data);
    end

    if any(data.experimenter(1) == 'rosenbaum')
        data = metadata.rosenbaumDecentralized(data);
        data = metadata.modifyModulatorOn(data,'../annotations/rosenbaum-modulator-on.txt');
    end

    if any(data.experimenter(1) == 'schneider')
        data = metadata.modifyModulatorOn(data,'../annotations/schneider-modulator-on.txt');
    end

    if any(data.experimenter(1) == 'haley')
        data = metadata.haley(data);
    end



    H = structlib.md5hash(data);

    cache_path = fullfile(getpref('embedding','cache_loc'),[H '.mat']);

	% check the cache
	if exist(cache_path) ~= 2  
		% cache miss
		disp(['cache miss: ' this_exp])


        try
    	   data = embedding.DataStore(data);
        catch
            % something went wrong, give up
            disp(['Something went wrong with: ' all_exps(i).name])
            continue
        end

    	if any(data.mask==1)
    		% measure ISIs
            data = computeISIs(data);
            alldata(i) = data;

    	end

        save(cache_path,'data','-v7.3')


    	
    else
    	% cache hit
        disp(['cache hit: ' all_exps(i).name])
    	load(cache_path,'data')

    	alldata(i) = data;
	end

end



clearvars data

alldata = alldata(:);


% throw out all the placeholder data (defined as data where filename isn't defined)

rm_this = false(length(alldata),1);

for i = 1:length(alldata)
    if any(isundefined(alldata(i).filename))
        rm_this(i) = true;
    end
end

alldata(rm_this) = [];


save('../cache/alldata.mat','alldata')