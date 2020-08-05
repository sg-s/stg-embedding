function markModulatorOn(src, value)

data_idx = src.Parent.UserData.data_idx;

filename = src.Parent.UserData.filename(src.Parent.UserData.ph.YData(1));
time = src.Parent.UserData.time(src.Parent.UserData.ph.YData(1));
experiment_idx = src.Parent.UserData.experiment_idx;

load('../annotations/rosenbaum_modulator_on.mat','mmm')

mmm = [mmm;struct('filename',filename,'time',time,'experiment_idx',experiment_idx)];

save('../annotations/rosenbaum_modulator_on.mat','mmm')

src.Enable = 'off';