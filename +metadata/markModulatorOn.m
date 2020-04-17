function markModulatorOn(src, value)

data_idx = src.Parent.UserData.data_idx;

data = evalin('base','data');

data(data_idx).modulator = ((data(data_idx).mask)*0);
data(data_idx).modulator(src.Parent.UserData.ph.YData(1):end) = 1;

assignin('base','data',data);