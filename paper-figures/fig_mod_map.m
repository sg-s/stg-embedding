% makes a figure showing the map, and colors points by condition
% the state is indicated by a shading in the background,
% and sub-clusters are found using watershed


close all
init()



cats = categories(alldata.idx);
colors = display.colorscheme(cats);

figure('outerposition',[30 10 1002 1801],'PaperUnits','points','PaperSize',[1002 1801]); hold on
clf;
ax = axlib.tight_subplot(2,2);

for i = 1:length(ax)
	ax(i).XLim = [min(R(:))-5 max(R(:))+5];
	ax(i).YLim = [min(R(:))-5 max(R(:))+5];
	axis(ax(i),'on')
	box(ax(i),'on')
	ax(i).XTick = [];
	ax(i).YTick = [];
	hold(ax(i),'on')

	display.plotBackgroundLabels(ax(i),alldata, R)
end


figlib.pretty('LineWidth',1)




modulators = {'RPCH','proctolin','oxotremorine','serotonin'};

temp = struct;

for ci = 1:length(modulators)

	% find all pts where the modulator is used
	plot_this = hashes.moddata(moddata.(modulators{ci})>0);
	plot_this = ismember(hashes.alldata,plot_this);


	for i = 1:length(cats)
		if strcmp(cats{i},'regular')
			x = R(alldata.idx == cats(i) & plot_this,1);
			y = R(alldata.idx == cats(i) & plot_this,2);
			prep = alldata.experiment_idx(alldata.idx == cats(i) & plot_this);
		end
		plot(ax(ci),R(alldata.idx == cats(i) & plot_this,1),R(alldata.idx == cats(i) & plot_this,2),'.','Color',colors(cats{i}),'MarkerSize',15)
	end

	N = length(unique(moddata.experiment_idx(moddata.(modulators{ci})>0)));
	title(ax(ci),[modulators{ci} ' (N = ' mat2str(N) ')'],'FontWeight','normal')

	temp(ci).x = x;
	temp(ci).y = y;
	temp(ci).prep = prep;
	
end


% are the distributions different?
p = NaN(length(modulators));
for i = 1:length(modulators)-1
	for j = i+1:length(modulators)

		% average over preps
		A = [analysis.averageBy(temp(i).x,temp(i).prep) analysis.averageBy(temp(i).y,temp(i).prep)];
		B = [analysis.averageBy(temp(j).x,temp(j).prep) analysis.averageBy(temp(j).y,temp(j).prep)];

		[~,p(i,j)] = statlib.kstest_2s_2d(A,B);
		if p(i,j) < 0.05/(length(modulators)-1)
			disp(['Difference b/w ' modulators{i} ' and ' modulators{j}])
		end
	end
end





figlib.saveall('Location',display.saveHere,'Format','png')
display.trimImage([mfilename '_1.png']);


init()