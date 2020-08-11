

% this function gets all the data, gets the embedding, the labelling
% and presents this data to other scripts

function init()

% make sure you tell the script
% where the data is located using
% setpref('embedding','data_root','/Volumes/DATA/')

if isempty(getpref('embedding'))
    error('You need to say where the data is located')
end


% get data
data = sourcedata.getAllData();


data = filter(data,sourcedata.DataFilter.Baseline);



% combine into a single structure
alldata = combine(data);

[p, VectorisedPercentiles] = spikes2percentiles(alldata,'ISIorders',[1 2]);


% load saved data
load('../annotations/labels.c8ache','H','idx','-mat')


clear m
m.RawData = [alldata.LP, alldata.PD];
m.idx = embedding.makeCategoricalArray(size(VectorisedPercentiles,1));
m.idx = embedding.readAnnotations(idx,H,m.RawData,m.idx);

for i = 1:length(m.idx)
    corelib.textbar(i,length(m.idx))
    this_hash = hashlib.md5hash(m.RawData(i,:));
    loc = find(strcmp(this_hash,H));
    if ~isempty(loc)
        loc = loc(1);
        m.idx(i) = idx(loc);
    end
end
clearvars H idx

idx = m.idx;

u = umap;
u.n_neighbors = 150;
u.min_dist = 1;
u.negative_sample_rate = 25;
u.learning_rate = 2;
u.repulsion_strength = 2;
u.labels = idx;

R = u.fit(VectorisedPercentiles);

% clean up cats
cats = unique(idx);
cats = corelib.categorical2cell(unique(idx));
all_cats = categories(idx);
remove_cats =  setdiff(all_cats,cats);
for i = 1:length(remove_cats)
    idx = removecats(idx,remove_cats{i});
end



alldata.idx = idx;
alldata.R = R;

assignin('base','data',data)
assignin('base','alldata',alldata)
assignin('base','p',p)
assignin('base','VectorisedPercentiles',VectorisedPercentiles)

return














%



return




mask = vertcat(alldata.mask);

% show centralized and well into decentralized
time_since_mod_on = vertcat(data.time_since_mod_on);
centralized = logical(0*time_since_mod_on);
centralized(time_since_mod_on<-600) = true;

decentralized_only = logical(0*time_since_mod_on);
decentralized_only(time_since_mod_on>-600 & time_since_mod_on < 0) = true;

centralized = centralized(mask);
decentralized_only = decentralized_only(mask);




% color points by decentralized or not


figure('outerposition',[300 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)

plot(R(centralized,1),R(centralized,2),'.','Color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',8);

plot(R(decentralized_only,1),R(decentralized_only,2),'.','Color',[1 0 0],'MarkerFaceColor',[1 0 0],'MarkerSize',8);

figlib.pretty()
axis off







% color points by experiment ID

exp_idx = vertcat(data.experiment_idx);
exp_idx = exp_idx(mask);
N = length(categories(exp_idx));
cats = categories(exp_idx);
C = lines(N);
M = reshape(repmat({'+','x','.','^'},ceil(N/4),1), ceil(N/4)*4,1);


figure('outerposition',[300 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)

for i = 1:N
    plot_this = exp_idx == cats(i);
    plot(R(plot_this,1),R(plot_this,2),'Color',C(i,:),'MarkerSize',5,'Marker',M{i},'LineStyle','none')
end

figlib.pretty()
axis off






% plot the different neuromodulators

C = [lines(8); 1 0 0];

figure('outerposition',[300 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)



for i = 1:length(neuromodulators)
    plot_this = (allnm.(neuromodulators{i})>0);
    plot(R(plot_this,1),R(plot_this,2),'.','Color',C(i,:),'MarkerFaceColor',C(i,:),'MarkerSize',8);
end



figlib.pretty()
axis off



% show different conditions by experiment
all_exp_idx = categories(exp_idx);

for show_this = 5:62

    figure('outerposition',[900 300 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on

    plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',35)

    % plot control
    plot_this = (decentralized == 0 & exp_idx == all_exp_idx{show_this});
    plot(R(plot_this,1),R(plot_this,2),'.','Color',[0 1 0],'MarkerFaceColor',[0 1 0],'MarkerSize',8);

    % plot decentralized
    plot_this = (decentralized == 1 & exp_idx == all_exp_idx{show_this});
    plot(R(plot_this,1),R(plot_this,2),'.','Color',[0 0 1],'MarkerFaceColor',[0 0 1],'MarkerSize',20);

    % plot neuromodulator
    plot_this = (any_neuromodulator == 1 & exp_idx == all_exp_idx{show_this});
    plot(R(plot_this,1),R(plot_this,2),'.','Color',[1 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',20);

    title(show_this)
end
