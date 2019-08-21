

clear d
temp = vertcat(plot_data.LP, plot_data.PD)';
d = dataExplorer('reduced_data',R,'make_axes',false); 
d.full_data = temp;
d.makeFigure; d.addMainAx(6,1,1:5); d.addAx(6,1,6);
d.callback_function = @plot_LP_PD;
