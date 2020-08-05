% searches all the data and returns baseline data
function data = getAllData()

if exist('../cache/alldata.mat','file')

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
for i = length(all_exps):-1:1 %length(all_exps):-1:1


	if strcmp(all_exps(i).name(1),'.')
		continue
	end

	this_exp = all_exps(i).name;
	


    % get the consolidated data from crabsort
    % this is internally cached
    alldata{i} = crabsort.consolidate(this_exp,'neurons',{'PD','LP'});

    H = structlib.md5hash(alldata{i});

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
        for j = 1:length(alldata{i})
            alldata{i}(j).LP = sort(alldata{i}(j).LP,'ascend');
            alldata{i}(j).PD = sort(alldata{i}(j).PD,'ascend');
        end

        alldata{i} = crabsort.analysis.stack(alldata{i},options);
        alldata{i} = crabsort.analysis.chunk(alldata{i},options);

    	data = embedding.DataStore(alldata{i});


    	if ~any(data.mask)
            save(cache_path,'data','-v7.3')
    		continue
    	end


        % delete spikes that are closer than 3ms to other spikes
        min_isi = .003;
        for j = 1:length(data.mask)
            spikes = data.LP(:,j);
            delete_these = find(diff(spikes)<min_isi);
            if ~isempty(delete_these)
                data.LP(delete_these,j) = NaN;
                data.LP(:,j) = sort(data.LP(:,j));
            end

            spikes = data.PD(:,j);
            delete_these = find(diff(spikes)<min_isi);
            if ~isempty(delete_these)
                data.PD(delete_these,j) = NaN;
                data.PD(:,j) = sort(data.PD(:,j));
            end
        end


    	% measure ISIs
		data = thoth.computeISIs(data, {'LP','PD'});

    	save(cache_path,'data','-v7.3')

    else
    	% cache hit
        disp(all_exps(i).name)
    	load(cache_path,'data')
    	alldata{i} = data;
	end

end

data = embedding.DataStore.cell2array(alldata);


% need to read metadata for the cronin data because fuck me 
data = metadata.cronin(data,fullfile(getpref('embedding','cache_loc'),'cronin-metadata'));



% use default values for metadata 
defaults = metadata.defaults;
fn = fieldnames(defaults);


for i = 1:length(data)
    for j = 1:length(fn)
        temp = data(i).(fn{j});
        temp(isnan(temp)) = defaults.(fn{j});
        data(i).(fn{j}) = temp;
    end
end


% clean up the channel names a little
for i = 1:length(data)
    data(i).LP_channel(data(i).LP_channel == 'LP2') = 'LP';
    data(i).PD_channel(data(i).PD_channel == 'PD2') = 'PD';
    data(i).PD_channel(data(i).PD_channel == 'pdn2') = 'pdn';
end

save('../cache/alldata.mat','data')