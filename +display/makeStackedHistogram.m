

function makeStackedHistogram(alldata)

close all
figure('outerposition',[300 300 1400 1111],'PaperUnits','points','PaperSize',[1400 1111]); hold on


clear ax
modnames = {'proctolin','CabTrp1a','RPCH','oxotremorine',};

idx = alldata.idx;

cats = categories(idx);
colors = display.colorscheme(cats);

preps = categories(alldata.experiment_idx);
time = -600:20:600;
	Nexp = length(preps);

all_cats = {};

for mi = 1:length(modnames)

	ax(mi) = subplot(2,2,mi); hold on

	state_matrix = categorical(NaN(length(time),Nexp));

	for i = 1:Nexp

		if all(isnan(alldata.(modnames{mi})(alldata.experiment_idx == preps{i})))
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
		state_hist(i,:) = histcounts(state_matrix(i,:),categories(idx))/sum(~isundefined(state_matrix(i,:)));
	end

	% compute switching rates across population
	temp = diff(double(state_matrix));
	switching_rates = NaN*time;
	for i = 1:length(switching_rates)-1
		switching_rates(i+1) = mean((~isnan(temp(i,:)) & temp(i,:)~=0));
	end


	a = area(time,state_hist);

	all_cats = [all_cats; cats];

	for i = 1:length(a)
		a(i).FaceColor = colors(cats{i});
		a(i).EdgeColor = brighten(colors(cats{i}),-.8);
	end

	set(gca,'YLim',[0 1],'YTick',[])
	title(modnames{mi},'FontWeight','normal')

	if mi > 2
		xlabel('Time since modulator application (s)')
	end
end


all_cats = unique(all_cats);
% make fake plots for a legend
clear lh
for i = 1:length(all_cats)
    lh(i) = plot(ax(2),NaN,NaN,'.','MarkerSize',50,'DisplayName',all_cats{i},'Color',colors(all_cats{i}));
end


L = legend(lh);
L.NumColumns = 1;
L.Position = [.73 .1 .3 .8];

axlib.move(ax([1 3]),'left',.1)
axlib.move(ax([2 4]),'left',.15)

for i = 1:length(ax)
	ax(i).Position(3) = .33;
end


figlib.pretty('PlotLineWidth',1)