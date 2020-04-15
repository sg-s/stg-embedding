function embed(src,value)


m = evalin('base','m');
idx = m.idx;

% read out the labels
idx2 = double(idx);
idx2(isnan(idx2)) = -1;

assignin('base','annotation',idx2);

evalin('base','u.labels = annotation;')

R = evalin('base','u.fit(RawData);');



m.ReducedData = R;

m.idx = idx;


m.handles.AllReducedData.XData = R(:,1);
m.handles.AllReducedData.YData = R(:,2);


for i = 1:length(m.handles.ReducedData)
	m.handles.ReducedData(i).XData = R(idx == m.handles.ReducedData(i).Tag,1);
	m.handles.ReducedData(i).YData = R(idx == m.handles.ReducedData(i).Tag,2);
end

m.handles.ax(1).XLim = [min(m.ReducedData(:,1)) max(m.ReducedData(:,1))];
m.handles.ax(1).YLim = [min(m.ReducedData(:,2)) max(m.ReducedData(:,2))];

disp(['Sorting ' mat2str(mean(~isundefined(m.idx))*100,2) '% done!'])