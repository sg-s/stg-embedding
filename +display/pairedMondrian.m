% makes three plots:
% 1. mondrian plot in case A
% 2. mondrian plot in case B
% 3. bar graph comparing fold change from A to B
% 
% provide a single axes handle to it, and it will delete it
% and make its own axes within the space of that axes


function ax = pairedMondrian(ax,alldata, A, B, A_label, B_label)

arguments
	ax (1,1) matlab.graphics.axis.Axes
	alldata (1,1) embedding.DataStore
	A (:,1) logical
	B (:,1) logical
	A_label char
	B_label char
end


assert(length(A)==length(B),'Expected A and B to be of the same length')
assert(length(A)==length(alldata.mask),'DataStore length does not match A and B')


% delete the ax handle provided, and create 3 new axes in that physical location

Pos = ax.Position;

frame = ax;
axis(frame,'off');

ax(1) = axes();
ax(1).Position = [Pos(1:2) Pos(3)/4 Pos(4)];

ax(2) = axes();
ax(2).Position = [Pos(1) + 1.1*(Pos(3)/4) Pos(2) Pos(3)/4 Pos(4)];


ax(3) = axes();
ax(3).Position = [Pos(1) + 2.6*(Pos(3)/4) Pos(2) Pos(3)/2 Pos(4)];
hold on



idx = alldata.idx;
cats = categories(idx);
colors = display.colorscheme(cats);



% compute probabilities of states in both conditions
P.A = alldata.probState(A);
P.B = alldata.probState(B);




axes(ax(1))
view([90 -90])
ax(1).XLim = [0 1];
ax(1).YLim = [0 1];
axis(ax(1),'off')


p = display.mondrian(nanmean(P.A),cats);
% p = display.mondrian(histcounts(alldata.idx(A)),cats);

axes(ax(2))
axis(ax(2),'off')
ax(2).XLim = [0 1];
ax(2).YLim = [0 1];
view([90 -90])

p2 = display.mondrian(nanmean(P.B),cats);
% p2 = display.mondrian(histcounts(alldata.idx(B)),cats);


p_values = NaN(length(cats),1);
n_A = histcounts(alldata.idx(A),cats);
n_B = histcounts(alldata.idx(B),cats);
N = 1e5;
N_samples_required = NaN*p_values;
tic
parfor i = 1:length(p_values)
	%p_values(i) = ranksum(P.A(:,i),P.B(:,i));
	p_values(i) = statlib.pairedPermutationTest(P.A(:,i),P.B(:,i),N);

end
toc


for i = 1:length(N_samples_required)
	S = std(P.A(:,i));
	if S == 0
		N_samples_required(i) = 1;
		continue
	end
	N_samples_required(i) = sampsizepwr('t',[mean(P.A(:,i)) S],mean(P.B(:,i)),.9);
end




disp(['p-values using ' mat2str(N) ' permutations'])

delta_p = nanmean(P.B - P.A);
delta_p = delta_p';

table(cats,n_A',n_B',p_values,delta_p,N_samples_required)



%  plot fold change 
fold_change = (nanmean(P.B) - nanmean(P.A))./(nanmean(P.B) + nanmean(P.A));


[~,sidx] = sort(fold_change);



% to compute errors, we need to propagate them correctly
E = sqrt((std(P.B)./mean(P.B)).^2 + (std(P.A)./mean(P.A)).^2).*fold_change;
E  = E./sqrt(length(unique(alldata.experiment_idx)));

axes(ax(3))
for i = 1:length(cats)
	
	plotlib.barWithErrorStar(i,fold_change(sidx(i)), E(sidx(i)),false,'Color',colors(cats{sidx(i)}));
	if p_values(sidx(i)) > .05/length(p_values)
		th = text(i,-.1,'n.s.','FontSize',15);
		th.Rotation = 90;
		th.HorizontalAlignment = 'right';
	end
end
ax(3).YScale = 'linear';
ax(3).YLim = [-1.5 1.5];
ax(3).XLim = [0 sum(~isnan(fold_change))+1];
ylabel(ax(3),['Fold change(norm)'])
ax(3).XTick = [];
ax(3).XColor = 'w';
ax(3).YTick = [-1:.5:1];
ax(3).YGrid = 'on';

axlib.move(ax(1:2),'left',.02)


title(ax(2),{B_label,['(n = ' mat2str(sum(B)) ')']},'FontWeight','normal')

title(ax(1),{A_label,['(n = ' mat2str(sum(A)) ', N = ' mat2str(size(P.A,1)) ')']},'FontWeight','normal')