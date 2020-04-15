

% make sure data directory exists
filelib.mkdir('cache')

data_root = '/Volumes/DATA/philipp/';

all_exps = dir(data_root);
all_exps(cellfun(@(x) strcmp(x(1),'.'),{all_exps.name})) = [];
all_exps = {all_exps.name};

if exist('cache/PD_LP.mat','file') ~= 2

    

    disp('Assembling data from source...')
  
    for i = length(all_exps):-1:1

        disp(all_exps{i})

        data{i} = crabsort.consolidate('neurons',{'PD','LP'},'stack',true,'DataDir',[data_root all_exps{i}],'ChunkSize',20);
    end

    data = structlib.cell2array(data);

    save('cache/PD_LP.mat','data','-v7.3')

else
    load('cache/PD_LP.mat')
end


% manually fill in some metadata by eyeballing data
% for i = 1:length(all_exps)

%     f = figure; neurolib.raster(data{i}.LP,'split_rows',true); title(char(data{i}.experiment_idx(1)),'interpreter','none'); set(gcf,'WindowButtonDownFcn',@temp_mouse_callback)

%     plotlib.horzline(find(data{i}.decentralized,1,'first'),'LineWidth',2);

%     fn = fieldnames(data{i});
%     mod_name = setdiff(fn,{'PD','LP','experiment_idx','mask','filename','temperature','decentralized','time_offset'});

%     plotlib.horzline(find(data{i}.(mod_name{1}),1,'first'),'LineWidth',2);

%     uiwait(f)

% end


% fill in empty metadata
fn = fieldnames(data);
for i = 1:length(data)
    for j = 1:length(fn)
        if isempty(data(i).(fn{j}))
            N = size(data(i).LP,2);
            data(i).(fn{j}) = NaN(N,1);
        end
    end
end


% load the manually annotated metadata and combine with all data
load('manual_modulator_metadata.mat','mmm');
 
for i = 1:length(data)
    this_exp = data(i).experiment_idx(1);
    idx = find(mmm.all_exp_idx == this_exp,1,'last');
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


% measure ISIs
data = thoth.computeISIs(data, {'LP','PD'});

% disallow ISIs below 10ms
for i = 1:length(data)
    data(i).PD_PD(data(i).PD_PD<.01) = NaN;
    data(i).LP_LP(data(i).LP_LP<.01) = NaN;
end


% combine all data
for i = 1:length(data)
    data(i).PD = data(i).PD';
    data(i).LP = data(i).LP';
    data(i).PD_PD = data(i).PD_PD';
    data(i).PD_LP = data(i).PD_LP';
    data(i).LP_LP = data(i).LP_LP';
    data(i).LP_PD = data(i).LP_PD';
    data(i).time_offset = data(i).time_offset';
end

fn = fieldnames(data);
for i = 1:length(fn)
    alldata.(fn{i}) = vertcat(data.(fn{i}));
end

% purge masked data
rm_this = ~alldata.mask;
for i = 1:length(fn)
    alldata.(fn{i}) = alldata.(fn{i})(~rm_this,:);
end




N = length(alldata.mask);

% compute cumulative histograms for all ISIs
clear cdfs
types = {'PD_PD','LP_LP','LP_PD','PD_LP'};
nbins = 100;
bins = logspace(-2,1,nbins+1);
for i = 1:length(types)
    cdfs.(types{i}) = NaN(N,nbins);

    for j = 1:N
        temp = alldata.(types{i})(j,:);
        temp(isnan(temp)) = [];
        if isempty(temp)
            continue
        end

        cdfs.(types{i})(j,:) = histcounts(temp,bins,'Normalization','cdf');
    end

end

% directly t-sne them, using a firing rate ansatz


% re-intialize
% cats = categories(m.idx);
% for i = 1:length(cats)
%     R(m.idx == cats{i},1) = i;
%     R(m.idx == cats{i},1) = rem(i,4);
% end


% t = TSNE('implementation',TSNE.implementation.fitsne);
% RawData = [cdfs.PD_PD, cdfs.LP_LP, cdfs.LP_LP, cdfs.PD_LP];
% RawData(isnan(RawData)) = 0;
% t.RawData = RawData;
% t.InitialSolution = R;
% t.perplexity = 500;
% t.NIter = 1e3;
% t.Alpha = .75;
% R = t.fit;

load('embedding.mat','R','idx')





% figure out the modulator used in each prep
modnames = {'CCAP','CabTrp1a','RPCH','dopamine','octopamine','oxotremorine','pilocarpine','proctolin','serotonin'};
modulator_used = {};
for i = length(data):-1:1
    for j = 1:length(modnames)
        if any(data(i).(modnames{j})>0)
            modulator_used{i} = modnames{j};
        end
    end
end

[~,sidx] = sort(lower(modulator_used));
sorted_mods = modulator_used(sidx);

% make a figure summarizing all the states in all the experiments, arranged by prep


return



% now show the map with the states identified in it and examples of each state

cats = categories(idx);

clear ax
figure('outerposition',[300 300 2000 999],'PaperUnits','points','PaperSize',[2000 999]); hold on

pidx = 1;
for i = 1:3
    for j = 1:7
        ax.examples(pidx) = subplot(7,3,pidx); hold on
        
        set(ax.examples(pidx),'YLim',[-.01 2.01],'XLim',[-.5 10])
        pidx = pidx + 1;
    end
end

ax.main = subplot(1,3,1); hold on
axis off
ax.examples = ax.examples(isvalid(ax.examples));


plot(ax.main,R(:,1),R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)
for i = 1:length(cats)
    plot(ax.main,R(idx==cats{i},1),R(idx==cats{i},2),'.','Color',C(i,:),'MarkerSize',10)
    axis square
end


show_these = [ 520 5261 1061 4337 3958 5937 2412 47 3334  4028 5189 1554 6449 562];

for i = 1:length(show_these)
    axes(ax.examples(i))
    PD = alldata.PD(show_these(i),:);
    LP = alldata.LP(show_these(i),:);
    offset = nanmin([LP(:); PD(:)]);
    PD = PD - offset;
    LP = LP - offset;
    neurolib.raster(PD,'deltat',1,'center',false)
    neurolib.raster(LP,'deltat',1,'center',false,'yoffset',1,'Color','r')
    title(char(idx(show_these(i))),'FontWeight','normal')

    ax.examples(i).YTick = [];
    ax.examples(i).XTick = [];
    ax.examples(i).Box = 'on';
    axis(ax.examples(i),'on')
    this_color = C(find(strcmp(cats,char(idx(show_these(i))))),:);
    plotlib.vertline(ax.examples(i),-.45,'Color',this_color,'LineWidth',10);
    ax.examples(i).Color = [.95 .95 .95];

end


figlib.pretty('LineWidth',1)


axlib.move(ax.examples,'right',.05)
axlib.move(ax.examples(1:2:end),'right',.05)

ax.main.Position = [.06 .1 .4 .8];
ax.examples(1).YTick = [.5 1.5];
ax.examples(1).YTickLabel = {'PD','LP'};























return











% % add all of this to the ISI database
% for i = 1:length(data)
%     thoth.add(data(i),'neurons',{'PD','LP'});
% end



% [D, isis] = thoth.getDistances('isi_types', {'PD_PD','PD_LP','LP_LP','LP_PD'},'experiments',all_exps,'Variant',5);


D = sum(D,3);

% purge elements that are masked
mask = logical(vertcat(data.mask));
D = D(mask,mask);
isis = isis(:,mask,:);


mdata = struct;
mdata.LP = data(1).LP';
mdata.PD = data(1).PD';

for i = 2:length(data)
    mdata.LP = vertcat(mdata.LP, data(i).LP');
    mdata.PD = vertcat(mdata.PD, data(i).PD');
end


% purge useless data
mdata.LP = mdata.LP(mask,:);
mdata.PD = mdata.PD(mask,:);


% initialize t-SNE with firing rate solution
LPf = sum(~isnan(mdata.LP)');
PDf = sum(~isnan(mdata.PD)');

% use this
t = TSNE; 
t.perplexity = 400;
t.Alpha = .7;
t.InitialSolution = [zscore(LPf); zscore(PDf)]';
t.DistanceMatrix = D;
t.NIter  = 1e3;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;


return



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
