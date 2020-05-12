function pairedMondrian(ax,alldata, modulator)

% delete the ax handle provided, and create 3 new axes in that physical location

Pos = ax.Position;

frame = ax;
axis(frame,'off');

ax(1) = axes();
ax(1).Position = [Pos(1:2) Pos(3)/4 Pos(4)];
title(ax(1),'decentralized','FontWeight','normal')

ax(2) = axes();
ax(2).Position = [Pos(1) + 1.1*(Pos(3)/4) Pos(2) Pos(3)/4 Pos(4)];
title(ax(2),['+' modulator],'FontWeight','normal')

ax(3) = axes();
ax(3).Position = [Pos(1) + 2.6*(Pos(3)/4) Pos(2) Pos(3)/2 Pos(4)];
hold on



idx = alldata.idx;

cats = categories(idx);
colors = display.colorscheme(cats);

preps = unique(alldata.experiment_idx);
Nexp = length(preps);

all_cats = {};

time = -600:20:600;
state_matrix = categorical(NaN(length(time),Nexp));

tick = 0;

for i = 1:Nexp

	% skip this prep if it doesn't have the mod we are intereste din

	if all(isnan(alldata.(modulator)(alldata.experiment_idx == preps(i))))
		continue
	end

	if max(alldata.(modulator)(alldata.experiment_idx == preps(i))) == 0 
		continue
	end

	tick = tick +1;


	this_time = alldata.time_since_mod_on(alldata.experiment_idx == preps(i));
	these_states = idx(alldata.experiment_idx == preps(i));


	for j = 1:length(time)
		if time(j) > 0
			continue
		end
		insert_this = find(this_time == time(j));
		if isempty(insert_this)
			continue
		end

		state_matrix(j,i) = these_states(insert_this);

	end


	% now insert the states corresponding to the highest mod
	max_mod = max(alldata.(modulator)(alldata.experiment_idx == preps(i)));
	max_mod_start = find(alldata.(modulator)(alldata.experiment_idx == preps(i)) == max_mod,1,'first');
	if this_time(max_mod_start) > 0
		this_time = this_time - this_time(max_mod_start);
	end

	% now we have time starting at 0 when the max mod is there, so continue inserting
	for j = 1:length(time)
		if time(j) <= 0
			continue
		end
		insert_this = find(this_time == time(j));
		if isempty(insert_this)
			continue
		end

		state_matrix(j,i) = these_states(insert_this);

	end


end


% computer a per-prep state histogram
decentralized_counts = zeros(Nexp,length(cats)); 
modulator_counts = zeros(Nexp,length(cats)); 

for i = 1:Nexp

	decentralized_counts(i,:) = histcounts(state_matrix(1:30,i),categories(idx));
	modulator_counts(i,:) = histcounts(state_matrix(31:end,i),categories(idx));
end

rm_this = sum(modulator_counts' + decentralized_counts') == 0;
state_matrix(:,rm_this) = [];
modulator_counts(rm_this,:) = [];
decentralized_counts(rm_this,:) = [];



% convert into probabilities

decentralized_p = decentralized_counts;
modulator_p = modulator_counts;
for i = 1:size(decentralized_counts,1)
	decentralized_p(i,:) = decentralized_counts(i,:)./sum(decentralized_counts(i,:));
	modulator_p(i,:) = modulator_counts(i,:)./sum(modulator_counts(i,:));
end




axes(ax(1))
view([90 -90])
ax(1).XLim = [0 1];
ax(1).YLim = [0 1];
axis(ax(1),'off')
decentralized_p(isnan(decentralized_p)) = 0;
p = display.mondrian(mean(decentralized_p),colors,cats);

axes(ax(2))
axis(ax(2),'off')
ax(2).XLim = [0 1];
ax(2).YLim = [0 1];
view([90 -90])
p2 = display.mondrian(mean(modulator_p),colors,cats);


p_values = NaN(length(cats),1);
for i = 1:length(p_values)
	p_values(i) = ranksum(decentralized_p(:,i),modulator_p(:,i));
end


for i = 1:length(p_values)
	if p_values(i) < .05
		p2(i).EdgeColor = 'k';
		p(i).EdgeColor = 'k';
		p2(i).LineWidth = 3;
		p(i).LineWidth = 3;
		uistack(p(i),'top')
		uistack(p2(i),'top')
	end
end

% also plot probabilities of state before and after modulator application
% for i = 1:length(cats)
% 	xe = std(decentralized_p(:,i))/sqrt(Nexp);
% 	ye = std(modulator_p(:,i))/sqrt(Nexp);
% 	x = mean(decentralized_p(:,i));
% 	y = mean(modulator_p(:,i));

% 	if x < 1e-2
% 		continue
% 	end

% 	if y < 1e-2
% 		continue
% 	end

% 	errorbar(ax(3),x,y,xe,xe,ye,ye,'o','MarkerFaceColor',colors(cats{i}),'LineStyle','none','MarkerEdgeColor',colors(cats{i}),'Color',colors(cats{i}),'MarkerSize',9)
% end

% ax(3).XScale = 'log';
% ax(3).YScale = 'log';
% ax(3).YLim = [1e-2 1];
% ax(3).XLim = [1e-2 1];
% axis(ax(3),'square')
% plotlib.drawDiag(ax(3));


% alternative -- plot fold change 
fold_change = (mean(modulator_p) - mean(decentralized_p))./(mean(modulator_p) + mean(decentralized_p));
[~,sidx] = sort(fold_change);



% to compute errors, we need to propagate them correctly
E = sqrt((std(modulator_p)./mean(modulator_p)).^2 + (std(decentralized_p)./mean(decentralized_p)).^2).*fold_change;
E  = E./sqrt(Nexp);

axes(ax(3))
for i = 1:length(cats)
	
	h = bar(i,fold_change(sidx(i)),'BaseValue',0);
	h.FaceColor = colors(cats{sidx(i)});
	h.EdgeColor = colors(cats{sidx(i)});
	er = errorbar(i,fold_change(sidx(i)),E(sidx(i)),E(sidx(i)));    
	er.Color = colors(cats{sidx(i)});
	er.LineStyle = 'none';  
end
ax(3).YScale = 'linear';
ax(3).YLim = [-1.5 1.5];
ax(3).XLim = [0 sum(~isnan(fold_change))+1];
ylabel(ax(3),'Change from decentralized (norm)')
ax(3).XTick = [];
ax(3).XColor = 'w';
ax(3).YTick = [-1:.5:1];
ax(3).YGrid = 'on';

axlib.move(ax(1:2),'left',.02)