



% make sure you tell the script
% where the data is located using
% setpref('embedding','data_root','/Volumes/DATA/')

if isempty(getpref('embedding'))
    error('You need to say where the data is located')
end


% get data
data = sourcedata.get('modulators');


% get metadata for the Cronin data
data = metadata.cronin(data,pathlib.join(getpref('embedding','data_root'),'cronin-metadata'));


% % manually fill in some metadata by eyeballing data
% all_exps = unique(vertcat(data.experiment_idx));

% for i = 1:length(all_exps)

%     f = figure('outerposition',[300 300 1200 1000],'PaperUnits','points','PaperSize',[1200 1000]); hold on
%     f.WindowButtonDownFcn =  @metadata.mouseCallback;
%     c = lines;
%     filebreaks = [];
%     ii=1;
%     for j = 2:size(data(i).LP,2)
%         if data(i).filename(j) ~= data(i).filename(j-1)
%             ii = ii +1;
%             filebreaks = [filebreaks j];
%         end

%         neurolib.raster(data(i).LP(:,j),'split_rows',true,'yoffset',j,'Color',c(ii,:),'LineWidth',5)

%     end

%     time = (1:size(data(i).LP,2))*20;
%     for j = 1:length(filebreaks)
%         time(filebreaks(j):end) = time(filebreaks(j):end) - time(filebreaks(j));
%     end

%     f.UserData.time = time;
%     f.UserData.filename = data(i).filename;

%     f.UserData.ph = plotlib.horzline(10,'Color','k','Tag','horzline');

%     f.UserData.data_idx = i;

%     % add buttons for marking decentralized and modulator 
%     uicontrol('Parent',f,'Style','pushbutton','String','Mark decentralized','Units','normalized','Position',[0.1 .01 .2 .1],'Callback',@metadata.markDecentralized);


%     uicontrol('Parent',f,'Style','pushbutton','String','Mark modulator+','Units','normalized','Position',[0.5 .01 .2 .1],'Callback',@metadata.markModulatorOn);


%     % open up the metadata file
%     edit(pathlib.join(getpref('embedding','data_root'),'cronin-metadata',[char(all_exps(i)),'.txt']))

%     f.Name = char(all_exps(i));

%     uiwait(f)

% end



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



[alldata, data] = sourcedata.combine(data);

p = sourcedata.spikes2percentiles(alldata,'ISIorders',[1 2]);



% assuming you have annotated the data and made the supervised embedding...
load('cronin_22_april.mat','idx','R')









% make a colorscheme
cats = unique(idx);
C = colormaps.dcol(length(cats));

colors = dictionary;
for i = 1:length(cats)
    colors.(cats(i)) = C(i,:);
end

colors('normal') = color.aqua('blue');
colors('LP-weak-skipped') = color.aqua('brown');
colors('PD-weak-skipped') = color.aqua('green');
colors('sparse-irregular') = color.aqua('indigo');
colors('LP-silent-PD-bursting') = color.aqua('orange');
colors('LP-silent') = color.aqua('pink');

% color points by whether they are phillip's or cronin's 

temp = alldata.experiment_idx;
for i = length(temp):-1:1
    exp_num(i) = str2double(strrep(char(temp(i)),'_',''));
end

figure('outerposition',[300 300 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on
plot(R(:,1),R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)
clear l
l(1) = plot(R(exp_num>8e5,1),R(exp_num>8e5,2),'.','Color',[245, 150, 142]/255,'MarkerSize',10);
l(2) = plot(R(exp_num<8e5,1),R(exp_num<8e5,2),'.','Color','b','MarkerSize',10);
legend(l,{'Philipp R','Liz C'})
figlib.pretty
axis off













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
