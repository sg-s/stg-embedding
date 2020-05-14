% color points by whether they are phillip's or cronin's 

if ~exist('alldata','var')
    init()
end

temp = alldata.experiment_idx;
for i = length(temp):-1:1
    exp_num(i) = str2double(strrep(char(temp(i)),'_',''));
end

figure('outerposition',[300 300 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on
plot(alldata.R(:,1),alldata.R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)
clear l

names = unique(alldata.experimenter_name);

c = lines;

for i = 1:length(names)
	plot(alldata.R(alldata.experimenter_name == names(i),1),alldata.R(alldata.experimenter_name == names(i),2),'.','MarkerSize',10,'Color',c(i,:));
end

% fake some plots
for i = 1:length(names)
	l(i) = plot(NaN,NaN,'.','MarkerSize',40,'Color',c(i,:));
end

legend(l,categories(alldata.experimenter_name))
figlib.pretty('FontSize',30)
axis off



clearvars -except p alldata data