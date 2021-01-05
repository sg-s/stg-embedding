

init
close all



% compute the time of decentralization and make a vector
% for this
time_since_decentralization = analysis.timeSinceDecentralization(decdata);
all_preps = unique(decdata.experiment_idx);

% first make line plots for baseline and decentralized

figure('outerposition',[300 300 1200 1300],'PaperUnits','points','PaperSize',[1200 1300]); hold on


% show activity before decentralization
ax(1) = subplot(4,1,1:3); hold on

set(ax(1),'XLim',[-600 1800])


YOffset = 0;


for i = 1:length(all_preps)
	use_this = decdata.experiment_idx == all_preps(i);
	states = decdata.idx(use_this);
	time = time_since_decentralization(use_this);

	if sum(time == 600) == 0
		continue
	end

	show_this = time > -600 & time < 1800;
	display.plotStates(ax(1), states(show_this), time(show_this), YOffset);

	YOffset = YOffset + 1;


end

disp(YOffset)
ax(1).YLim = [0 YOffset];


r1 = rectangle(ax(1),'Position',[.205 .04 .47 .745],'FaceColor',[.85 .85 .85 ],'EdgeColor',[.85 .85 .85]);
r1.Position = [0 -2 2e3 YOffset+4];
uistack(r1,'bottom');

ax(1).XColor = 'w';
ax(1).YColor = 'w';





% compute probabilities of states as a function of time
time = -600:20:1800;
cats = categories(decdata.idx);
colors = display.colorscheme(cats);
state_probability = zeros(length(time),length(cats));


prep_counts = 0*time;

for i = 1:length(time)
	idx = decdata.idx(time_since_decentralization==time(i));
	preps = decdata.experiment_idx(time_since_decentralization==time(i));
	state_probability(i,:) = histcounts(idx,'Normalization','probability');
	prep_counts(i) = length(unique(preps));
end



switching_rate = 0*time;
switching_rate_N = 0*time;
% find the switching rates by going prep by prep
for i = 1:length(all_preps)
	use_this = decdata.experiment_idx == all_preps(i);
	idx = decdata.idx(use_this);
	this_time = time_since_decentralization(use_this);

	for j = 1:length(time)-1
		prev_state = idx(this_time == time(j));
		next_state = idx(this_time == time(j+1));
		if isempty(prev_state) | isempty (next_state)
			continue
		end
		if isundefined(prev_state) | isundefined(next_state)
			continue
		end
		switching_rate_N(j) = switching_rate_N(j) + 1;

		if prev_state ~= next_state
			switching_rate(j) = switching_rate(j)+1;
		end
	end

end
switching_rate = switching_rate./switching_rate_N;


% smooth them a little bit
for i = 1:length(cats)
	state_probability(:,i) = filtfilt(ones(2,1),2,state_probability(:,i));
end



ax(2) = subplot(4,1,4); hold on
h = area(time/60,state_probability);
for i = 1:length(h)
	h(i).LineStyle = 'none';
	h(i).FaceColor = colors(cats{i});
end

% also plot the switching rate
switching_rate(end) = switching_rate(end-1);
switching_rate = switching_rate/max(switching_rate);
switching_rate = switching_rate*.2;

YOffset = 1.03;
switching_rate = switching_rate + YOffset;

p = polyshape([time/60 max(time)/60 time(1)/60], [switching_rate YOffset YOffset]);
h = plot(p);

h.LineStyle = 'none';
h.FaceColor = 'k';

axis(ax(2),'on')
ax(2).YColor = 'w';

ax(2).XLim = [min(time)/60 max(time/60)];
ax(2).YLim = [-.01 1.2];

xlabel(ax(2),'Time since decentralization (min)')


plot(ax(2),[0 0],[0 1],'w--');




ax(1).Position = [.1 .47 .8 .5];
ax(2).Position = [.1 .1 .8 .35];


figlib.pretty()

figlib.label('FontSize',30,'XOffset',-.01,'YOffset',-.05)

% cleanup
figlib.saveall('Location',display.saveHere)



init()