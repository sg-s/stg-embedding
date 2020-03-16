function temp_mouse_callback(src,value)

ax = gca;

p = round(ax.CurrentPoint(1,2));
t = ax.Title.String;

load('manual_modulator_metadata.mat','mmm')

mmm.all_exp_idx = [mmm.all_exp_idx; categorical(cellstr(t))];
mmm.modulator_start = [mmm.modulator_start; p];

save('manual_modulator_metadata.mat','mmm')

title(ax,p)