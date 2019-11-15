

temp = horzcat(mdata.LP, mdata.PD);





m = clusterlib.manual;
m.RawData = temp;
m.ReducedData = R;
m.DisplayFcn = @plot_LP_PD;
m.makeUI
m.handles.ax(1).Position = [0 .4 .55 .55];
axis(m.handles.ax(2),'normal')
m.handles.ax(2).Position = [0.02 0.02 .9 .25];