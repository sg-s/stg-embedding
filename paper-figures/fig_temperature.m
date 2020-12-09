
close all
init

% analysis of pH perturbations 



% throw out non-PH data
data = alldata.slice(alldata.pH~=7);




Nbins = 50;

% compute probabilities of states as a function of pH
ph_space = linspace(5.5,10.5,Nbins);
cats = categories(data.idx);
colors = display.colorscheme(cats);
state_probability = zeros(length(ph_space),length(cats));

bin_width = mean(diff(ph_space))/2;

prep_counts = 0*ph_space;

for i = 1:length(ph_space)

	a = ph_space(i) - bin_width;
	z = ph_space(i) + bin_width;

	idx = data.idx(data.pH>a & data.pH < z);
	preps = data.experiment_idx(data.pH>a & data.pH < z);
	state_probability(i,:) = histcounts(idx,'Normalization','probability');
	prep_counts(i) = length(unique(preps));
end

state_probability(isnan(state_probability)) = 0;

% smooth them a little bit
state_probability = filtfilt(ones(floor(Nbins/10),1),floor(Nbins/10),state_probability);
for i = 1:size(state_probability)
	state_probability(i,:) = abs(state_probability(i,:));
	state_probability(i,:) = state_probability(i,:)/sum(state_probability(i,:));
end

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

h = area(ph_space,state_probability);
for i = 1:length(h)
	h(i).LineStyle = 'none';
	h(i).FaceColor = colors(cats{i});
end



