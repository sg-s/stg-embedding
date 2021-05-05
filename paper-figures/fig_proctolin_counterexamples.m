% the purpose of this figure is to show raw
% traces where proctolin is added and a normal
% rhythm is not observed, which is contrary 
% to conventional wisdom

close all

figure('outerposition',[300 300 901 1222],'PaperUnits','points','PaperSize',[901 1222]); hold on

clear ax
for i = 8:-1:1
	ax(i) = subplot(4,2,i); hold on;
end

% Sara
display.showRawData('ax',ax(1),'t_start',20,'experiment_idx','828_052_2','filename','828_052_0048.crab');
display.showRawData('ax',ax(2),'t_start',0,'experiment_idx','828_058','filename','828_058_0099.crab');


% Liz
display.showRawData('ax',ax(3),'t_start',1000,'experiment_idx','140_086','filename','190607_EMC_140_006.crab');
display.showRawData('ax',ax(4),'t_start',316,'experiment_idx','140_088','filename','190613_EMC_140_004.crab','nerves',{'LP','PD'});

% Anna
display.showRawData('ax',ax(5),'t_start',342,'experiment_idx','138_040','filename','2017_12_11_ACS_138_040_0002.crab','nerves',{'lpn','pdn'});
display.showRawData('ax',ax(6),'t_start',318,'experiment_idx','138_042','filename','2017_12_12_ACS_138_042_0002.crab','nerves',{'lpn','pdn'});

% Philipp
display.showRawData('ax',ax(7),'t_start',632,'experiment_idx','876_127','filename','876_127_0011.abf','nerves',{'LP','PD'});
display.showRawData('ax',ax(8),'t_start',431,'experiment_idx','876_129','filename','876_129_0008.abf','nerves',{'LP','lvn'});

figlib.label('YOffset',-.03)
figlib.pretty