% make sure data directory exists
filelib.mkdir('cache')

addpath('../')

data_dirs = {'904_054','906_120','931_016','904_051','930_037','906_126','904_066','930_045'};

ptx_start = [52, 54, 42, 50, 36, 34, 64, 42]*3;
high_k_start = [80, 86, 72, 70, 74, 74, 94, 70]*3;
high_k_end = [170, 178, 162, 160, 168, 166, 184, 160]*3;

if exist('cache/all_high_k_data.mat','file') ~= 2

    disp('Assembling data from source...')

    data_root = '/Volumes/HYDROGEN/srinivas_data/high-k-data/intra_2_5k_PTX/use-these';
    



    if ~exist('data','var')

        for i = length(data_dirs):-1:1

            data(i) = crabsort.consolidate('neurons',{'PD'},'stack',true,'DataDir',[data_root filesep data_dirs{i}],'ChunkSize',20);

        end

    end

    save('cache/all_high_k_data.mat','data','-v7.3')

else
    load('cache/all_high_k_data.mat')
end

% add all of this to the ISI database
for i = 1:length(data)
    thoth.add(data(i),'neurons',{'PD'});
end


% Assume that the distances are computed on a cluster, and you have access
% to the data...

[D, isis] = thoth.getDistances(data_dirs, {'PD_PD'});

t = TSNE; t.distance_matrix = D;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;



% measure firing rates in every sample
for i = 1:length(data)
    data(i).firing_rates = zeros(length(data(i).mask),1);
    for j = 1:length(data(i).mask)
        data(i).firing_rates(j) = sum(~isnan(data(i).PD(:,j)));
    end
end




% make some metadata vectors
for i = 1:length(data)
    data(i).after_ptx = logical(0*data(i).mask);
    data(i).before_highk = logical(0*data(i).mask);
    data(i).after_highk = logical(0*data(i).mask);
    data(i).after_ptx(ptx_start(i):end) = true;
    data(i).before_highk(1:high_k_start(i)) = true;
    data(i).after_highk(high_k_end(i):end) = true;
end


all_before_high_k = vertcat(data.before_highk);
all_after_high_k = vertcat(data.after_highk);
all_after_ptx = vertcat(data.after_ptx);


% f = figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
% ax = gca;


% spiketimes = [data.PD];

% M = clusterlib.manual('ReducedData',R,'RawData',isis); 
% M.makeUI;
% M.MouseCallback = @(x) plotRaster(x, ax);




% show coloured by firing rates

figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[901 900]); hold on


firing_rates = vertcat(data.firing_rates)/20;
[~,ch]=plotlib.cplot(R(:,1),R(:,2),firing_rates);
title(ch,'Firing rate (Hz)')
axis off


figlib.pretty;







% colour by experiment


figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[901 900]); hold on
all_exp_id = (vertcat(data.experiment_idx));
u = unique(all_exp_id);
c = colormaps.linspecer(length(u));
for i = 1:length(u)
    plot(R(all_exp_id==u(i),1),R(all_exp_id==u(i),2),'.','MarkerFaceColor',c(i,:),'MarkerEdgeColor',c(i,:),'MarkerSize',20)
end
axis off
title('Coloured by experiment ID')

figlib.pretty
pdflib.snap




% effect of PTX


figure('outerposition',[300 300 700 700],'PaperUnits','points','PaperSize',[1200 600]); hold on

C = [.8 .8 .8];
plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)

% plot before high k in black dots
plot_this = all_before_high_k & all_after_ptx;
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',12)

% plot after high k in red
plot_this = ~all_after_ptx;
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',12)


axis off
title('Before and after PTX')

figlib.pretty
pdflib.snap








% colour by whether before or after high K

figure('outerposition',[300 300 700 700],'PaperUnits','points','PaperSize',[1200 600]); hold on

C = [.8 .8 .8];
plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)

% plot before high k in black dots
plot_this = all_before_high_k & all_after_ptx;
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',12)

% plot after high k in red
plot_this = all_after_high_k;
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',12)


axis off
title('Before and after perturbation')

figlib.pretty
pdflib.snap



return


% plot time in high K
figure('outerposition',[300 300 700 700],'PaperUnits','points','PaperSize',[1200 600]); hold on

C = [.8 .8 .8];
plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)

plot_this = ~isnan(all_time_in_high_K);
[~,ch]=plotlib.cplot(R(plot_this,1),R(plot_this,2),all_time_in_high_K(plot_this)/60);

axis off
ch.Location = 'southoutside';
title(ch,'Time in high K+ (min)')
figlib.pretty








% show different states
load('data/labels')
subplot(1,2,2); hold on
c = lines(8);
M = {'o','.','+','*','x','s','d','^','p'};
c(end,:) = 0;
for i = 1:length(names)
    plot(R(L==i,1),R(L==i,2),M{i},'MarkerFaceColor',c(i,:),'MarkerEdgeColor',c(i,:),'DisplayName',names{i})
end
axis off


figlib.pretty
pdflib.snap




% Ok, now show the different states
figure('outerposition',[300 300 1300 901],'PaperUnits','points','PaperSize',[1200 600]); hold on
for i = 1:length(names)
    show_this = veclib.shuffle(find(L == i));
    subplot(2,4,i); hold on
    for j = 1:5
        neurolib.ISIraster(all_isis(:,show_this(j)),'deltat',1,'Color','k','yoffset',j)
    end
    set(gca,'XLim',[.1 10])
    axis off

end

figlib.pretty





figure('outerposition',[300 300 1400 700],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(1,2,1); hold on
C = [.8 .8 .8];
plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)

plot_this = (all_before_high_k) & all_ptx;
C = 'k';
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',10)

plot_this = (all_after_high_k) & all_ptx;
C = 'r';
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',10)
axis off












figure('outerposition',[300 300 903 901],'PaperUnits','points','PaperSize',[1200 600]); hold on
% plot trajectories

for i = 1:8
    subplot(3,3,i); hold on
    C = [.8 .8 .8];
    plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)


    plot(R(all_exp_id==u(i),1),R(all_exp_id==u(i),2),'Color',[1 .7 .7])
    plot(R(all_exp_id==u(i),1),R(all_exp_id==u(i),2),'.','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10)
    axis square
    axis off
    title(strlib.oval(u(i)))

end

figlib.pretty()
pdflib.snap()




%% How to reproduce this document
% 

%%
% First, get the code: 

pdflib.footer;

%%
% Then, run this script:

disp(mfilename)

