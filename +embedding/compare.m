function compare(a,b)

p = evalin('base','p');

fn = fieldnames(p);

A = zeros(length(fn),1);
B = A;

for i = 1:length(A)
	A(i) = p.(fn{i})(a);
	B(i) = p.(fn{i})(b);
end

D = round(100*abs(A-B)./(A+B));

[D,idx] = sort(D);
A = A(idx);
B = B(idx);

T = table(A,B,D,'RowNames',fn(idx));
disp(T)


m = evalin('base','m');
m.handles.CurrentPointReduced.XData = m.ReducedData([a b],1);
m.handles.CurrentPointReduced.YData = m.ReducedData([a b],2);