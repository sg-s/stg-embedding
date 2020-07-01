% searches all the data and returns baseline data
function data = getAllData()

filelib.mkdir(getpref('embedding','cache_loc'))



% get a list of all experiments in the crabsort spikes folder
spikesfolder = getpref('crabsort','store_spikes_here');
all_exps = dir(spikesfolder);

% purge junk
all_exps = all_exps([all_exps.isdir]);
all_exps(cellfun(@(x) strcmp(x(1),'.'),{all_exps.name})) = [];

% first check that everything is cached nicely
for i = length(all_exps):-1:1


	if strcmp(all_exps(i).name(1),'.')
		continue
	end

	this_exp = all_exps(i).name;
	cache_path = fullfile(getpref('embedding','cache_loc'),[this_exp '.mat']);



	% check the cache
	if exist(cache_path) ~= 2 
		% cache miss
		disp(this_exp)

    	alldata{i} = crabsort.consolidate(this_exp,'neurons',{'PD','LP'});


        % stack and chunk
        options.dt = 1e-3;
        options.ChunkSize = 20;
        options.neurons = {'PD','LP'};

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
    	load(cache_path,'data')


        if isstruct(data)
            disp('Converting to embedding.DataStore...')
            data = embedding.DataStore(data);
            save(cache_path,'data')
        end

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
