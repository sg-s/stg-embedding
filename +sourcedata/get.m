function data = get(folder_name)

data_root = pathlib.join(getpref('embedding','data_root'),folder_name);

all_exps = dir(data_root);
all_exps(cellfun(@(x) strcmp(x(1),'.'),{all_exps.name})) = [];
all_exps = {all_exps.name};


cache_name = pathlib.join(data_root,'cache','PD_LP.mat');

if exist(cache_name,'file') ~= 2

    

    disp('Assembling data from source...')
  
    for i = length(all_exps):-1:1

        disp(all_exps{i})

        data{i} = crabsort.consolidate('neurons',{'PD','LP'},'stack',true,'DataDir',[data_root all_exps{i}],'ChunkSize',20);
    end

    data = structlib.cell2array(data);

    save(cache_name,'data','-v7.3')

else
    load(cache_name,'data')
end
