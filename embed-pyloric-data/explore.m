

temp = horzcat(mdata.LP, mdata.PD);

% clear d

% d = dataExplorer('reduced_data',R,'make_axes',false); 
% d.full_data = temp;
% d.makeFigure; d.addMainAx(6,1,1:5); d.addAx(6,1,6);
% d.callback_function = @plot_LP_PD;





m = clusterlib.manual;
m.RawData = temp;
m.ReducedData = R;
m.DisplayFcn = @plot_LP_PD;
m.makeUI
m.handles.ax(1).Position = [0 .4 .55 .55];
axis(m.handles.ax(2),'normal')
m.handles.ax(2).Position = [0.02 0.02 .9 .25];