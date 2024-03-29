% the point of this figure is to show that intracellular 
% recording can cause non-normal behavior in baseline

close all
init()

% drawing constants
extra_color = [.1 .1 .1];
intra_color = [.9 0 0];

cats = categories(alldata.idx);
reg_idx = find(strcmp(cats,'regular'));

DataSize = length(basedata.mask);


colors = display.colorscheme(basedata.idx);




figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on



% distribution of p(normal) across all preps
p = basedata.probState();

ax.prob_normal = subplot(3,3,1); hold on
display.plotCDFWithError(p(:,reg_idx));
set(gca,'XLim',[0 1])


% does recording type correlate with normal behavior? 

ax.LP_extra = subplot(3,3,4); hold on
temp = basedata.purge(basedata.LP_channel == 'gpn');
temp.LP_channel(temp.LP_channel ~= 'LP') = 'LP-extra';
temp.LP_channel(temp.LP_channel == 'LP') = 'LP-intra';


[means, group_idx] = temp.probStateGroupedBy('regular', 'LP_channel');

C = [extra_color; intra_color];

groups = unique(group_idx);

for i = 1:length(groups)
	[~, shade(i)] = display.plotCDFWithError(means(group_idx==groups(i)),C(i,:));
	lines(i) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',C(i,:),'MarkerFaceColor',C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end

set(gca,'XTickLabel',{},'XLim',[0 1],'YLim',[0 1])
legend(lines,cellfun(@char,{groups},'UniformOutput',false),'Location','northwest')

[~,p]=kstest2(means(group_idx=='LP-intra'),means(group_idx~='LP-intra'));
th = text(.45,.85,['\itp = ' corelib.num2tex(p)]);





subplot(3,3,7); hold on
temp = basedata;
temp.PD_channel(temp.PD_channel ~= 'PD') = 'PD-extra';
temp.PD_channel(temp.PD_channel == 'PD') = 'PD-intra';

[means, group_idx] = temp.probStateGroupedBy('regular', 'PD_channel');
groups = unique(group_idx);
clear lines shade
for i = 1:length(groups)
	[~, shade(i)] = display.plotCDFWithError(means(group_idx==groups(i)),C(i,:));
	lines(i) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',C(i,:),'MarkerFaceColor',C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end

legend(lines,cellfun(@char,{groups},'UniformOutput',false),'Location','northwest')
xlabel('p(regular)')
set(gca,'XLim',[0 1],'YLim',[0 1])

[~,p]=kstest2(means(group_idx=='PD-extra'),means(group_idx~='PD-extra'));
th = text(.45,.8,['\itp = ' corelib.num2tex(p)]);








% make treemaps to show distribution of all states

labels = {'both intra','LP intra','PD intra','both extra'};


ShowThese = zeros(length(basedata.idx),4);
ShowThese(:,1) = basedata.LP_channel == 'LP' & basedata.PD_channel == 'PD';
ShowThese(:,2) = basedata.LP_channel == 'LP' & basedata.PD_channel ~= 'PD';
ShowThese(:,3) = basedata.LP_channel ~= 'LP' & basedata.PD_channel == 'PD';
ShowThese(:,4) = basedata.LP_channel ~= 'LP' & basedata.PD_channel ~= 'PD';



cats = categories(basedata.idx);
for i = 1:size(ShowThese,2)
	subplot(4,3,3*(i)-1); hold on
	[h,P] = display.plotStateDistributionByPrep(basedata.idx, basedata.experiment_idx,ShowThese(:,i));
	delete(h)

	if i == 1
		ylabel('Preparation')
	end
	set(gca,'XColor','w')
	

	P = mean(P);

	display.mondrian(P,cats);
	text(.2,.5,[mat2str(P(reg_idx)*100,2) '%'],'Color','w','FontSize',128)
	title(labels{i},'FontWeight','normal')

	view([0 -90])
end






















ax.PD01 = subplot(4,3,3); hold on

temp = basedata.purge(basedata.LP_channel == 'gpn' );
temp.PD_channel(temp.PD_channel == 'PD') = 'PD-intra';
temp.PD_channel(temp.PD_channel ~= 'PD-intra') = 'PD-extra';

% group all aberrant PD weak states together
temp.idx(temp.idx == 'PD-silent') = 'PD-reduced';
temp.idx(temp.idx == 'PD-weak-skipped') = 'PD-reduced';

[means, group_idx] = temp.probStateGroupedBy('PD-reduced', 'PD_channel');

C = [intra_color; extra_color];
groups = categories(removecats(group_idx));
for i = 1:length(groups)
	[~, shade(i)] = display.plotCDFWithError(means(group_idx==groups{i}),C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end
xlabel('p(PD-reduced)')
lines(1) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',intra_color,'MarkerFaceColor',intra_color);
lines(2) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',extra_color,'MarkerFaceColor',extra_color);
legend(lines,{'PD-intra','PD-extra'},'Location','southeast')
[~,p]=kstest2(means(group_idx=='PD-intra'),means(group_idx=='PD-extra'));
text(.7,.6,['\itp = ' corelib.num2tex(p)]);
ax.PD01.XLim = [0 1];





ax.LP01 = subplot(4,3,6); hold on
temp = basedata.purge(basedata.PD_channel == 'PD' );
temp = temp.purge(temp.LP_channel == 'gpn' );
temp.LP_channel(temp.LP_channel == 'LP') = 'LP-intra';
temp.LP_channel(temp.LP_channel ~= 'LP-intra') = 'LP-extra';

temp.idx(temp.idx=='LP-silent') = 'LP-reduced';
temp.idx(temp.idx=='LP-weak-skipped') = 'LP-reduced';

[means, group_idx] = temp.probStateGroupedBy('LP-reduced', 'LP_channel');

C = [intra_color; extra_color];
groups = categories(removecats(group_idx));
for i = 1:length(groups)
	[~, shade(i)] = display.plotCDFWithError(means(group_idx==groups{i}),C(i,:));
end
for i = 1:length(shade)
	uistack(shade(i),'bottom')
end
lines(1) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',intra_color,'MarkerFaceColor',intra_color);
lines(2) = plot(NaN,NaN,'Marker','o','LineStyle','none','MarkerSize',10,'Color',extra_color,'MarkerFaceColor',extra_color);
legend(lines,{'LP-intra','LP-extra'},'Location','southeast')
xlabel('p(LP-reduced)')
[~,p]=kstest2(means(group_idx=='LP-intra'),means(group_idx=='LP-extra'));
text(.7,.6,['\itp = ' corelib.num2tex(p)]);
ax.LP01.XLim = [0 1];












figlib.pretty('FontSize',16)
ax.experimenter.YLim = [0 14];
ax.PD01.XColor = colors('PD-weak-skipped');
ax.LP01.XColor = colors('LP-weak-skipped');





% scale some plots and let them breate
ax.LP01.Position(4) =  ax.LP01.Position(4)*.9;
ax.PD01.Position(4) =  ax.PD01.Position(4)*.9;


% labels
figlib.label('XOffset',-.01,'FontSize',24,'ColumnFirst',true,'YOffset',-.01)


lax = axes;
lax.Position = [.69 .1 .25 .35];
lax = display.stateLegend(lax,cats,'NumColumns',2);



% cleanup
figlib.saveall('Location',display.saveHere)

display.trimImage([mfilename '_1.png']);


% this init clears all the junnk this script creates
init()








