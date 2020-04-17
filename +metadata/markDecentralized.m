function markDecentralized(src, value)

data_idx = src.Parent.UserData.data_idx;

data = evalin('base','data');

data(data_idx).decentralized = logical((data(data_idx).mask)*0);
data(data_idx).decentralized(src.Parent.UserData.ph.YData(1):end) = true;

assignin('base','data',data);