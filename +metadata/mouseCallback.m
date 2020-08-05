function mouseCallback(src,value)




ax = gca;

p = round(ax.CurrentPoint(1,2));
t = ax.Title.String;


% move the horzline to where it should be
src.UserData.ph.YData = [p p];

real_time = src.UserData.time(p);


title(ax,[char(src.UserData.filename(p)) ' --' mat2str(real_time)],'interpreter','none')

