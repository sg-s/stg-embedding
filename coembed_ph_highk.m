


filelib.mkdir('cache')


% define the data we are going to work on

highk_data_dirs = {'904_054','906_120','931_016','904_051','930_037','906_126','904_066','930_045'};
ph_data_dirs = {'877_093','887_081','887_005','897_005','887_049','897_037'};

highk_data_root = '/Volumes/HYDROGEN/srinivas_data/high-k-data/intra_2_5k_PTX/use-these';
ph_data_root = '/Volumes/HYDROGEN/srinivas_data/ph-data';

data_dirs = [highk_data_dirs, ph_data_dirs];



% get the ISIs and distances
[D, isis] = thoth.getDistances(data_dirs, {'PD_PD'});



% now get the actual data and metadata


addpath('../')

ptx_start = [52, 54, 42, 50, 36, 34, 64, 42]*3;
high_k_start = [80, 86, 72, 70, 74, 74, 94, 70]*3;
high_k_end = [170, 178, 162, 160, 168, 166, 184, 160]*3;

if exist('cache/all_high_k_data.mat','file') ~= 2

    disp('Assembling data from source...')

    
  
    for i = length(highk_data_dirs):-1:1
        data(i) = crabsort.consolidate('neurons',{'PD'},'stack',true,'DataDir',[highk_data_root filesep highk_data_dirs{i}],'ChunkSize',20);
    end

    save('cache/all_high_k_data.mat','data','-v7.3')

else
    load('cache/all_high_k_data.mat')
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



highk_data = data;
clear data


% get pH data

if exist('cache/all_ph_data.mat','file') ~= 2
    disp('Assembling data from source...')
    for i = length(ph_data_dirs):-1:1
        data(i) = crabsort.consolidate('neurons',{'PD'},'stack',false,'DataDir',[ph_data_root filesep ph_data_dirs{i}],'ChunkSize',20,'UseParallel',false, 'DataFun',{@getPH});
    end
    save('cache/all_ph_data.mat','data','-v7.3')
else
    load('cache/all_ph_data.mat')
end
ph_data = data;
clear data


% ph metadata
ph_data(1).ph_range = [5.5 10];
ph_data(2).ph_range = [6 10];
ph_data(3).ph_range = [5.5 9.5];
ph_data(4).ph_range = [5.5 10];
ph_data(5).ph_range = [5.5 10];
ph_data(6).ph_range = [5.5 10];

% correct the raw pH readings using this metadata
for i = 1:length(ph_data)
	ph = -ph_data(i).pH;
	ph = ph - min(ph);
	ph = ph/max(ph);

	ph = ph * diff(ph_data(i).ph_range);
	ph = ph + ph_data(i).ph_range(1);
	ph_data(i).pH = ph;
end





% harmonize the two data sets
ph_data = rmfield(ph_data, 'filename');
ph_data = rmfield(ph_data, 'ph_range');

data = structlib.merge(highk_data, ph_data);

% fill in some missing info with NaNs so we can collapse all data together
fn = fieldnames(data);
for i = 1:length(data)
	for j = 1:length(fn)
		if isempty(data(i).(fn{j}))
			data(i).(fn{j}) = NaN*data(i).mask;
		end
	end
end


% collapse all data into vectors
data = structlib.scalarify(data);

data.firing_rate = sum(~isnan(data.PD))/20;

% tsne the data 
t = TSNE; 
t.distance_matrix = D;
t.random_seed = 1990;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;


load('labels.mat')


% plot, colour by firing rate
figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[901 900]); hold on


[~,ch] = plotlib.cplot(R(:,1),R(:,2),data.firing_rate,'clim',[0 10],'colormap','colormaps.redula');
title(ch,'Firing rate (Hz)')
axis off


figlib.pretty;




% colour by pH, and indicate high K

figure('outerposition',[300 300 700 700],'PaperUnits','points','PaperSize',[1200 600]); hold on

C = [.5 .5 .5];
plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)


[~,ch] = plotlib.cplot(R(:,1),R(:,2),data.pH,'colormap','colormaps.redblue');


plot_this =data.after_highk == false & data.before_highk == false;
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize',5)


axis off

figlib.pretty;





% before and after PTX

figure('outerposition',[300 300 700 700],'PaperUnits','points','PaperSize',[1200 600]); hold on

C = [.8 .8 .8];
plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)

% after ptx
plot_this = data.before_highk == true & data.after_ptx == true;
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',9)


plot_this = (data.after_ptx == false) & isnan(data.pH);
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',9)


axis off
title('Before and after PTX')

figlib.pretty
pdflib.snap



% before and after high K


figure('outerposition',[300 300 700 700],'PaperUnits','points','PaperSize',[1200 600]); hold on

C = [.8 .8 .8];
plot(R(:,1),R(:,2),'.','MarkerFaceColor',C,'MarkerEdgeColor',C,'MarkerSize',20)

% plot before high k in black dots
plot_this = data.before_highk == true & data.after_ptx == true;
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',12)

% plot after high k in red
plot_this = (data.after_highk == true);
plot(R(plot_this,1),R(plot_this,2),'.','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',12)


axis off
title('Before and after high K')

figlib.pretty
pdflib.snap





% colour by experiment


figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[901 900]); hold on
all_exp_id = (data.experiment_idx);
u = unique(all_exp_id);
c = colormaps.linspecer(length(u));
for i = 1:length(u)
    plot(R(all_exp_id==u(i),1),R(all_exp_id==u(i),2),'.','MarkerFaceColor',c(i,:),'MarkerEdgeColor',c(i,:),'MarkerSize',20)
end
axis off
title('Coloured by experiment ID')

figlib.pretty
pdflib.snap





% build transition matrix

labels = unique(idx);
N = length(labels);
J = zeros(N);

idx2 = circshift(idx,1);

for i = 1:N
    for j = 1:N
        if i == j
            continue
        end
        J(i,j) = sum((idx == labels(i)).*(idx2 == labels(j)));
        % normalize
        J(i,j) = J(i,j)/sum(idx == labels(i));
    end
end

imagesc((J))
set(gca,'XTickLabelRotation',45)
set(gca,'XTickLabels',char(labels))
set(gca,'YTickLabels',char(labels))
set(gca,'YTickLabelRotation',45)
colormap hot



% make symbols for each state
S = {};
for i = 1:length(labels)
    S{i} = upper(cellfun(@(x) x(1), strsplit(char(labels(i)),'-')));
end


% show how we end up in a regular bursting state. 

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on



end_here = 2;
n_layers = 3;

cutoff = .05; % 5%

N = length(S);

set(gca,'XLim',[-n_layers - 1, 1],'YLim',[0 9]);


drawArrowsFromPrevLayer(J, S, 0, 2, n_layers, cutoff);

% first plot the final node
text(0, end_here, S{end_here},'FontWeight','bold');

for i = 1:n_layers

    for j = 1:N
        text(-i, j, S{j},'FontWeight','bold');
    end

end






% this is what I used to manually label the clusters
% f = figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
% ax = gca;

% M = clusterlib.manual('ReducedData',R,'RawData',isis); 
% M.idx = idx;
% M.makeUI;
% M.MouseCallback = @(x) plotRaster(x, ax);
