

function makeStackedHistogram(ax, alldata, modulator)


clear ax



idx = alldata.idx;

cats = categories(idx);
colors = display.colorscheme(cats);

preps = categories(alldata.experiment_idx);
time = -600:20:600;
Nexp = length(preps);

all_cats = {};



state_matrix = categorical(NaN(length(time),Nexp));

for i = 1:Nexp

	if all(isnan(alldata.(modulator)(alldata.experiment_idx == preps{i})))
		continue
	end

	this_time = (alldata.time_since_mod_on(alldata.experiment_idx == preps{i}));
	these_states = idx(alldata.experiment_idx == preps{i});

	for j = 1:length(time)
		insert_this = find(this_time == time(j));
		if isempty(insert_this)
			continue
		end

		state_matrix(j,i) = these_states(insert_this);

	end

end

state_hist = zeros(length(time),length(cats));



for i = 1:length(time)

	temp = state_matrix(i,:);
	N = sum(~isundefined(state_matrix(i,:)));
	temp = histcounts(temp,categories(idx));
	temp = temp/N;

	state_hist(i,:) = state_hist(i,:) + temp;
end


keyboard


a = area(time,state_hist);

all_cats = [all_cats; cats];

for i = 1:length(a)
	a(i).FaceColor = colors(cats{i});
	a(i).EdgeColor = brighten(colors(cats{i}),-.8);
end

set(gca,'YLim',[0 1],'YTick',[])


