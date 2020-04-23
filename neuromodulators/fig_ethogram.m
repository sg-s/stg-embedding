
% this script makes an ethogram of all experiments, and wordclouds for differnet regions




close all
figure('outerposition',[300 300 1333 900],'PaperUnits','points','PaperSize',[1333 900]); hold on



% figure out the modulator used in each prep
modnames = {'CCAP','CabTrp1a','RPCH','dopamine','octopamine','oxotremorine','pilocarpine','proctolin','serotonin'};
modulator_used = {};
for i = length(data):-1:1
    for j = 1:length(modnames)
        if any(data(i).(modnames{j})>0)
            modulator_used{i} = modnames{j};
        end
    end
end

[~,sidx] = sort(lower(modulator_used));
sorted_mods = modulator_used(sidx);


clear ax
ax.main = subplot(4,3,[4 5 7 8 10 11]); hold on
ax.normal = subplot(4,3,1); 
ax.decentralized = subplot(4,3,2);
ax.oxotremorine = subplot(4,3,9);
ax.RPCH = subplot(4,3,6);
ax.CabTrp1a = subplot(4,3,12);

preps = categories(alldata.experiment_idx);
preps = preps(sidx);


cats = corelib.categorical2cell(unique(idx));

yoffset = 1;

linepos = [];

for i = 1:length(preps)


    use_these = (alldata.experiment_idx == preps{i});
    decentralized = alldata.decentralized(use_these);
    time_since_mod_on = alldata.time_since_mod_on(use_these);

    % get states
    states = idx(use_these);

    y = time_since_mod_on*0 + yoffset;

    time_since_mod_on(time_since_mod_on == -600) = NaN;

    for j = 1:length(cats)

        yy = y;
        yy(states ~= cats{j}) = NaN;

        if all(isnan(yy))
            continue
        end

        % this effectively plots lines of continuous blocks
        plot(ax.main,time_since_mod_on,yy,'Color',colors(cats{j}),'LineWidth',4)

        % now what about single pts? 
        yy1 = circshift(yy,1);
        yy2 = circshift(yy,-1);

        isolated_pts = ~isnan(yy) & isnan(yy1) & isnan(yy2);

        plot(ax.main,time_since_mod_on(isolated_pts),yy(isolated_pts),'.','MarkerSize',10,'Color',colors(cats{j}),'LineStyle','none')


    end


    yoffset = yoffset + 1;

    if i < length(preps)
        if ~strcmp(sorted_mods{i},sorted_mods{i+1})
            plotlib.horzline(ax.main,yoffset + 1,'k:');
            linepos = [linepos; yoffset+1];
            yoffset = yoffset + 3;

            
        end
    end


end



% make fake plots for a legend
clear lh
for i = 1:length(cats)
    lh(i) = plot(ax.main,NaN,NaN,'.','MarkerSize',50,'DisplayName',cats{i},'Color',colors(cats{i}));
end


L = legend(lh);
L.NumColumns = 2;
L.Position = [0.6597 0.7487 0.2806 0.2025];


[~,temp]=unique(lower(sorted_mods));
umods = sorted_mods(temp);
linepos = [0; linepos] + diff([0; linepos; yoffset])/2;

for i = 1:length(umods)
    text(ax.main,1.1e3,linepos(i),umods{i},'HorizontalAlignment','left')
end

text(ax.main,-2500,yoffset+3,'control','FontSize',20,'Color',[0 0 0]);
text(ax.main,-660,yoffset+3,'decentralized','FontSize',20,'Color',[.6 .6 .6]);
text(ax.main,100,yoffset+5,'+modulator','FontSize',24,'Color',[1 .5 .5]);

r1 = rectangle(ax.main,'Position',[-600 -1 1.6e3 yoffset+1],'FaceColor',[.85 .85 .85 ],'EdgeColor',[.85 .85 .85]);
uistack(r1,'bottom');
r2 = rectangle(ax.main,'Position',[0 yoffset 1e3 2],'FaceColor',[1 0 0  .25],'EdgeColor',[1 0 0  .25]);
uistack(r1,'bottom');

set(ax.main,'XLim',[-2500 1000],'YLim',[-5 yoffset+7])


% wordcloud of normal
axes(ax.normal)
w = wordcloud(gcf,idx(~alldata.decentralized));
display.configureWordCloud(w,colors);

w_normal = w;



% decentralized
axes(ax.decentralized)
w = wordcloud(gcf,idx(alldata.decentralized & alldata.time_since_mod_on < 0));
display.configureWordCloud(w,colors);
w_decentralized = w;


show_these = {'RPCH','oxotremorine','CabTrp1a'};
for j = 1:length(show_these)

    axes(ax.(show_these{j}))
    w(j) = wordcloud(gcf,idx(alldata.(show_these{j})>0));

    display.configureWordCloud(w(j),colors);



end

ax.main.Position = [.02 .05 .6 .7];

figlib.pretty()
axis(ax.main,'off')



w(1).Position = [.75 .5 .2 .15];
w(2).Position = [.75 .25 .2 .15];
w(3).Position = [.75 .05 .2 .15];


a = annotation('textarrow');
a.Position = [0.7495   0.315  -0.024 0];


a = annotation('textarrow');
a.Position = [.75 .125 -.050 0];


a = annotation('textarrow');
a.Position = [.75 .585 -.07 0];



w_normal.Position = [.01 .77 .2 .15];
w_decentralized.Position = [.3 .77 .2 .15];


a = annotation('textarrow');
a.Position = [.04 .77 0 -.03];

a = annotation('textarrow');
a.Position = [.39 .77 0 -.03];

plot(ax.main,[-750 -650],[0 0],'k','LineWidth',4,'HandleVisibility','off')

axes(ax.main);
th = text(-800,-3,'100 s','FontSize',20);