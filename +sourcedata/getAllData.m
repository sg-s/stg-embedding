% searches all the data and returns baseline data
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

	this_exp = all_exps(i).name;

    % get the consolidated data from crabsort
    % this is internally cached
    data = crabsort.consolidate(this_exp,'neurons',{'PD','LP'});

    H = structlib.md5hash(data);

    cache_path = fullfile(getpref('embedding','cache_loc'),[H '.mat']);

	% check the cache
	if exist(cache_path) ~= 2 
		% cache miss
		disp(this_exp)

        % stack and chunk
        options.dt = 1e-3;
        options.ChunkSize = 20;
        options.neurons = {'PD','LP'};

        % make sure spikes are all sorted
        for j = 1:length(data)
            data(j).LP = sort(data(j).LP,'ascend');
            data(j).PD = sort(data(j).PD,'ascend');
        end

        data = crabsort.analysis.stack(data,options);
        data = crabsort.analysis.chunk(data,options);

        data.PD = transpose(data.PD);
        data.LP = transpose(data.LP);

        try
    	   data = embedding.DataStore(data);
        catch
            % something went wrong, give up
            continue
        end

    	if ~any(data.mask)
            save(cache_path,'data','-v7.3')
    		continue
    	end


        % delete spikes that are closer than 3ms to other spikes
        min_isi = .003;
        for j = 1:length(data.mask)
            spikes = data.LP(j,:);
            delete_these = find(diff(spikes)<min_isi);
            if ~isempty(delete_these)
                data.LP(j,delete_these) = NaN;
                data.LP(j,:) = sort(data.LP(j,:));
            end

            spikes = data.PD(j,:);
            delete_these = find(diff(spikes)<min_isi);
            if ~isempty(delete_these)
                data.PD(j,delete_these) = NaN;
                data.PD(j,:) = sort(data.PD(j,:));
            end
        end


    	% measure ISIs
		data = computeISIs(data);

    	save(cache_path,'data','-v7.3')

        alldata(i) = data;
    else
    	% cache hit
        disp(all_exps(i).name)
    	load(cache_path,'data')

    	alldata(i) = data;
	end

end


% make sure the idx is the same size as the mask
for i = 1:length(alldata)
    alldata(i).idx = repmat(categorical(NaN),length(alldata(i).mask),1);
end

clearvars data

alldata = alldata(:);



% need to read metadata for the cronin data because fuck me 
alldata = metadata.cronin(alldata,fullfile(getpref('embedding','cache_loc'),'cronin-metadata'));


% need to read metadata for the rosenbaum data because fuck me
alldata = metadata.rosenbaum(alldata);



% clean up the channel names a little
for i = 1:length(alldata)
    alldata(i).LP_channel(alldata(i).LP_channel == 'LP2') = 'LP';
    alldata(i).PD_channel(alldata(i).PD_channel == 'PD2') = 'PD';
    alldata(i).PD_channel(alldata(i).PD_channel == 'pdn2') = 'pdn';
end

save('../cache/alldata.mat','alldata')