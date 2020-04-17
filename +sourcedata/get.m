function data = get(folder_name)

data_root = pathlib.join(getpref('embedding','data_root'),folder_name);

all_exps = dir(data_root);
all_exps(cellfun(@(x) strcmp(x(1),'.'),{all_exps.name})) = [];
all_exps = {all_exps.name};

filelib.mkdir(pathlib.join(data_root,'cache'))
cache_name = pathlib.join(data_root,'cache','PD_LP.mat');

if exist(cache_name,'file') ~= 2

    

    disp('Assembling data from source...')
  
    for i = length(all_exps):-1:1

        disp(all_exps{i})

        data{i} = crabsort.consolidate('neurons',{'PD','LP'},'stack',true,'DataDir',pathlib.join(data_root,all_exps{i}),'ChunkSize',20);
    end

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


	% measure ISIs
	data = thoth.computeISIs(data, {'LP','PD'});

	% disallow ISIs below 10ms
	for i = 1:length(data)
	    data(i).PD_PD(data(i).PD_PD<.01) = NaN;
	    data(i).LP_LP(data(i).LP_LP<.01) = NaN;
	end


    save(cache_name,'data','-v7.3')

else
    load(cache_name,'data')
end


