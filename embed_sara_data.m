

% specify data files to work with:
data_files = {'828_001_1',...
              '828_042',...
              '828_128',...
              '857_016',...
              '857_020_1',...
              '857_104',...
              '857_080'};

data_dir = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding/';

if ~exist('data','var')
	for i = 1:length(data_files)
		data{i} =  crabsort.consolidate('neurons',{'LP','PD'},'DataDir',[data_dir data_files{i}],'stack',true,'ChunkSize',20);
	end
end                                                                                                  
% make a single dataset
cdata = struct;
for i = 1:length(data)
       cdata = structlib.merge(cdata,data{i});
end

for i = 1:length(cdata)
	fn = fieldnames(cdata);
	for j = 1:length(fn)
		if isempty(cdata(i).(fn{j}))
			cdata(i).(fn{j}) = NaN(size(cdata(i).mask,1),1);
		end
	end
end

cdata = structlib.scalarify(cdata);


thoth.add(data,'neurons',{'LP','PD'})


if  ~exist('D','var')
	[D,isis] = thoth.getDistances(data_files,{'PD_PD','PD_LP','LP_LP','LP_PD'});
end

allD = sum(D,3);

SS = 1;
t = TSNE; t.distance_matrix = allD(1:SS:end,1:SS:end);
t.perplexity = 70;
t.implementation = TSNE.implementation.vandermaaten;
R = t.fit;


d = dataExplorer('reduced_data',R,'full_data',[cdata.LP; cdata.PD],'make_axes',false); 
d.makeFigure; d.addMainAx(6,1,1:5); d.addAx(6,1,6);
d.callback_function = @plot_LP_PD;



figure('outerposition',[300 300 903 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

% colour by experiment
unique_exp = unique(cdata.experiment_idx);
subplot(2,2,1); hold on
plot(R(:,1),R(:,2),'k.')

for i = 1:length(unique_exp)
	plot(R(cdata.experiment_idx==unique_exp(i),1),R(cdata.experiment_idx==unique_exp(i),2),'.')
end
axis off

% colour by temperature
all_temp = 7:2:31;
subplot(2,2,2); hold on
plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerSize',32)
c = parula(length(all_temp));
for i = 1:length(all_temp)
	plot(R(cdata.temperature==all_temp(i),1),R(cdata.temperature==all_temp(i),2),'.','Color',c(i,:),'MarkerSize',24)
end
axis off

% colour by centralized
subplot(2,2,3); hold on
plot(R(:,1),R(:,2),'.','Color',[.8 .8 .8],'MarkerSize',32)
cdata.serotonin(isnan(cdata.serotonin)) = 0;
cdata.proctolin(isnan(cdata.proctolin)) = 0;
cdata.oxotremorine(isnan(cdata.oxotremorine)) = 0;

only_decentralized = cdata.decentralized == 1 & cdata.serotonin == 0 & cdata.proctolin == 0 & cdata.oxotremorine == 0;


plot(R(only_decentralized,1),R(only_decentralized,2),'k.','MarkerSize',10)
plot(R(cdata.proctolin>0,1),R(cdata.proctolin>0,2),'b.','MarkerSize',10)
plot(R(cdata.serotonin>0,1),R(cdata.serotonin>0,2),'g.','MarkerSize',10)
plot(R(cdata.oxotremorine>0,1),R(cdata.oxotremorine>0,2),'r.','MarkerSize',10)
axis off

figlib.pretty

