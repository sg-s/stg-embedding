
d = dataExplorer('reduced_data',R,'full_data',isis,'make_axes',false); 
d.makeFigure; d.addMainAx(6,1,1:5); d.addAx(6,1,6);
d.callback_function = @neurolib.ISIraster;
