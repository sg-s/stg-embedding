
% gets spike info from sorted data, finds ISIs,
% and caches them 
% preferentially loads from cache 
function data = get(varargin)

filelib.mkdir(pathlib.join(getpref('embedding','data_root'),'.cache'))


% first make a list of all experiments across all requested folders
all_exps = {};
experimenter_name = categorical.empty;
for i = 1:length(varargin)
	folder_name = varargin{i};

	data_root = pathlib.join(getpref('embedding','data_root'),folder_name);

	load_me = dir(data_root);
	load_me(cellfun(@(x) strcmp(x(1),'.'),{load_me.name})) = [];
	load_me = {load_me.name};

	for j = 1:length(load_me)
		load_me{j} = pathlib.join(data_root,load_me{j});
	end

	experimenter_name = [experimenter_name; repmat(categorical(varargin(i)),length(load_me),1)];

	all_exps = [all_exps, load_me];
end


% first check that everything is cached nicely
for i = length(all_exps):-1:1


	[~,this_exp]=fileparts(all_exps{i});
	cache_path = pathlib.join(getpref('embedding','data_root'),'.cache',[this_exp '.mat']);

	% check the cache
	if exist(cache_path) ~= 2
		% cache miss
		disp(all_exps{i})

    	alldata{i} = crabsort.consolidate('neurons',{'PD','LP'},'stack',true,'DataDir',all_exps{i},'ChunkSize',20);

    	data = alldata{i};

    	% measure ISIs
		data = thoth.computeISIs(data, {'LP','PD'});

		% disallow ISIs below 10ms
	    data.PD_PD(data.PD_PD<.01) = NaN;
	    data.LP_LP(data.LP_LP<.01) = NaN;


    	save(cache_path,'data','-v7.3')

    else
    	% cache hit
    	load(cache_path,'data')
    	alldata{i} = data;
	end

end


data = alldata;
data = structlib.cell2array(data);

% fill in empty metadata
fn = fieldnames(data);
for i = 1:length(data)
    for j = 1:length(fn)
        if isempty(data(i).(fn{j}))
            N = size(data(i).LP,2);
            data(i).(fn{j}) = NaN(N,1);
        end
    end
end

% fill in experimenter name
for i = 1:length(data)
	data(i).experimenter_name = repmat(experimenter_name(i),length(data(i).mask),1);
end
