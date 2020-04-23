% wrapper for ISI distance measurement

function D = measure(alldata, Variant)


D = neurolib.ISIDistance(alldata.PD_PD',[],Variant) + neurolib.ISIDistance(alldata.PD_LP',[],Variant) + neurolib.ISIDistance(alldata.LP_LP',[],Variant) + neurolib.ISIDistance(alldata.PD_PD',[],Variant);
