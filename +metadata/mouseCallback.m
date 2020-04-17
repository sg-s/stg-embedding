function mouseCallback(src,value)




ax = gca;

p = round(ax.CurrentPoint(1,2));
t = ax.Title.String;


% move the horzline to where it should be
src.UserData.ph.YData = [p p];

real_time = src.UserData.time(p);


title(ax,[char(src.UserData.filename(p)) ' --' mat2str(real_time)],'interpreter','none')
% load('manual_modulator_metadata.mat','mmm')

% mmm.all_exp_idx = [mmm.all_exp_idx; categorical(cellstr(t))];
% mmm.modulator_start = [mmm.modulator_start; p];

% save('manual_modulator_metadata.mat','mmm')

