% color points by whether they are phillip's or cronin's 


if ~exist('alldata','var')
	init
end

temp = alldata.experiment_idx;
for i = length(temp):-1:1
    exp_num(i) = str2double(strrep(char(temp(i)),'_',''));
end

figure('outerposition',[300 300 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on
plot(alldata.R(:,1),alldata.R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)
clear l
l(1) = plot(alldata.R(exp_num>8e5,1),alldata.R(exp_num>8e5,2),'.','Color',[245, 150, 142]/255,'MarkerSize',10);
l(2) = plot(alldata.R(exp_num<8e5,1),alldata.R(exp_num<8e5,2),'.','Color','b','MarkerSize',10);
legend(l,{'Philipp R','Liz C'})
figlib.pretty
axis off

