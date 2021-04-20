% The point of this figure is to show an example of
% of the normal rhythm and how it can get messed up
% and the challenges in identifying PY spikes 

import figlib.showImageInAxes

close all

figure('outerposition',[300 300 1200 999],'PaperUnits','points','PaperSize',[1200 999]); hold on

for i = 2:-1:1
	cartoon(i) = subplot(2,2,i*2 - 1);
	cartoon(i).Position(1) = .01;
	cartoon(i).Position(3) = .19;
	cartoon(i).Position(4) = .34;
	extracellulars(i) = subplot(2,2,i*2);
	extracellulars(i).Position(1) = .2;
	extracellulars(i).Position(3) = .7;
	hold on
	extracellulars(i).YLim = [-3.5 .5];
	axis(extracellulars(i),'off')
end

showImageInAxes(cartoon(1),imread('baseline.png'))
showImageInAxes(cartoon(2),imread('dec.png'))



% read the raw data and plot it
C = crabsort(false);
datafolder = crabsort.open('828_042_2',true);
C.path_name = datafolder.folder;

example_files = {'828_042_0000.smr','828_042_0033.smr'};


nerve_names = {'lvn','pdn','lpn','pyn'};

colors = colormaps.linspecer(4);
colors(1,:) = [.5 .5 .5];
scales = [4.7 .6 273    .5;  
		  4   .6 230.4  .4; 
		  4.2 .6 180    .6];

colorscheme = display.colorscheme(categorical(NaN));
colors(3,:) = colorscheme.LP;
colors(2,:) = colorscheme.PD;

for i = 1:length(example_files)
	C.file_name = example_files{i};
	C.loadFile;

	offset = 0;

	this_time = C.time > 10 & C.time < 20;

	for j = 1:length(nerve_names)
		nerve = nerve_names{j};
		temp = find(strcmp(C.common.data_channel_names,nerve));
		this = C.raw_data(this_time,temp);


		this = this/scales(i,j);
		this = this/2.5;

		plot(extracellulars(i),C.time(this_time),this+offset,'Color',colors(j,:));

		offset = offset - 1;

	end

	extracellulars(i).XLim = [10 20];


end

figlib.pretty


z = extracellulars(1).XLim(2);
a = extracellulars(1).XLim(1);
plot(extracellulars(1),[z-1 z],[-3.5 -3.5],'k','LineWidth',3)
text(extracellulars(1),19,-3.7,'1s','FontSize',20)

text(extracellulars(1),a-.1,0,'\it lvn','FontSize',20,'HorizontalAlignment','right')
text(extracellulars(1),a-.1,-1,'\it pdn','FontSize',20,'HorizontalAlignment','right')
text(extracellulars(1),a-.1,-2,'\it lpn','FontSize',20,'HorizontalAlignment','right')
text(extracellulars(1),a-.1,-3,'\it pyn','FontSize',20,'HorizontalAlignment','right')


th = text(extracellulars(1),10.1,-1.5,'PD','FontSize',18,'Color',colorscheme.PD);
 th = text(extracellulars(1),11.1,-1.45,'LP','FontSize',20,'Color',colorscheme.LP);
 th = text(extracellulars(1),12.06,-2.62,'}','FontSize',18,'Color',colors(4,:),'interpreter','none','Rotation',90);
th = text(extracellulars(1),12,-2.4,'PY','FontSize',20,'Color',colors(4,:),'interpreter','none');
axlib.label(extracellulars(1),'a','XOffset',-.15,'FontSize',28,'YOffset',-.02)
axlib.label(extracellulars(2),'b','XOffset',-.15,'FontSize',28,'YOffset',-.02)

figlib.saveall('Location',display.saveHere)

% clean up workspace
init()