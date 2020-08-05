

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


data = sourcedata.filter(data,sourcedata.DataFilter.Neuromodulator);


% create a modulator filed

mod_names = sourcedata.modulators;

for i = 1:length(data)
    modulator = 0*data(i).mask;
    for j = 1:length(mod_names)
        a = find(data(i).(mod_names{j})>0,1,'first');
        if isempty(a)
            continue
        end
        modulator(a:end) = 1;
    end
    data(i).addprop('modulator');
    data(i).addprop('time_since_mod_on');
    data(i).modulator = modulator;
end






% load the manually annotated metadata and combine with all data
load('manual_modulator_metadata.mat','mmm');
 
for i = 1:length(data)
    this_exp = data(i).experiment_idx(1);
    idx = find(mmm.all_exp_idx == this_exp,1,'last');
    if isempty(idx)
        continue
    end
    data(i).modulator = logical(0*data(i).mask);
    data(i).modulator(mmm.modulator_start(idx):end) = true;
end


% compute time since modulator application for each experiment. 
for i = 1:length(data)
    mod_on = find(data(i).modulator,1,'first');
    data(i).time_since_mod_on = (1:length(data(i).mask))';
    a = find(data(i).modulator,1,'first');
    data(i).time_since_mod_on = data(i).time_since_mod_on - a;
    data(i).time_since_mod_on = data(i).time_since_mod_on*20; % now in seconds
end



% mask decentralized data that is more than 10 minutes before 
% neuromodulator start
for i = 1:length(data)
    mask_me = data(i).decentralized == 1 & data(i).time_since_mod_on < -600;
    data(i).mask(mask_me) = 0;
end

% ignore data that is at a temperature other than 11
for i = 1:length(data)
    if data(i).experimenter(1) == 'haddad'
        data(i).mask(data(i).temperature ~= 11) = 0;
    end
end

% we're going to convert back into a structure array
[alldata, data] = sourcedata.combine(data);

[p, VectorisedPercentiles] = sourcedata.spikes2percentiles(alldata,'ISIorders',[1 2]);


% load saved data
load('../annotations/labels.cache','H','idx','-mat')

clear m
m.RawData = [alldata.LP, alldata.PD];
m.idx = embedding.makeCategoricalArray(size(VectorisedPercentiles,1));


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
u.n_neighbors = 75;
u.min_dist = .75;
u.negative_sample_rate = 25;
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



% show differnet conditions by experiment
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
