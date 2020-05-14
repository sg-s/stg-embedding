function n_transitions = plotTransitionGraph(idx, time)

validation.categoricalTime(idx,time);


cats = categories(idx);
colors = display.colorscheme(cats);

sz = histcounts(idx,cats);
sz = sz/sum(sz);

J = embedding.computeTransitionMatrix(idx, time);


% ignore transitions that occur only once or twice
J(J<2) = 0;


n_transitions = sum(J(:));


J = J./sum(J(:));


J = J + J';
G = graph(J); 



p = plot(G,'Layout','force'); 

W = 1 + .7*G.Edges.Weight/max(G.Edges.Weight);
W = W - min(W);
W = (W/max(W))*.6;
W = W + .4;

p.LineWidth = W*7;
p.EdgeColor = 1-repmat(W,1,3);

p.NodeLabel = {};


for i = 1:length(cats)
	if sum(J(i,:)) == 0
		continue
	end
	plot(p.XData(i),p.YData(i),'o','MarkerFaceColor',colors(cats{i}),'MarkerEdgeColor',colors(cats{i}),'MarkerSize',10+sz(i)*40)
end

% hide nonsense nodes

p.YData(sum(J) == 0) = p.YData(1);
p.XData(sum(J) == 0) = p.XData(1);


% zoom out a little bit
x = [min(p.XData) max(p.XData)];
xr = diff(x);
set(gca,'XLim',[x(1) - xr*.1 x(2) + xr*.1])

x = [min(p.YData) max(p.YData)];
xr = diff(x);
set(gca,'YLim',[x(1) - xr*.1 x(2) + xr*.1])


axis('off')


