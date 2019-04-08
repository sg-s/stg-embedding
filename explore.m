
d = dataExplorer('reduced_data',R,'full_data',horzcat(mdata.LP_LP, mdata.PD_PD)','make_axes',false); 
d.makeFigure; d.addMainAx(6,1,1:5); d.addAx(6,1,6);
d.callback_function = @plot_LP_PD;
