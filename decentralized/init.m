% make sure you tell the script
% where the data is located using
% setpref('embedding','data_root','/Volumes/DATA/')

if isempty(getpref('embedding'))
    error('You need to say where the data is located')
end


% get data
data = sourcedata.getAllData();


data = filter(data,sourcedata.DataFilter.Decentralized);

alldata = data.combine;