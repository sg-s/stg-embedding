% small shim to hide already sorted points

m.handles.AllReducedData.XData = m.ReducedData(isundefined(m.idx),1);
m.handles.AllReducedData.YData = m.ReducedData(isundefined(m.idx),2);

for i = 1:length(m.handles.ReducedData)
	m.handles.ReducedData(i).YData(:) = NaN;
end

m.handles.CurrentClass.XData = NaN;