
close all
figure('outerposition',[300 300 1333 900],'PaperUnits','points','PaperSize',[1333 900]); hold on


clear ax
ax.main = subplot(4,3,[4 5 7 8 10 11]); hold on
ax.normal = subplot(4,3,1); 
ax.decentralized = subplot(4,3,2);
ax.oxotremorine = subplot(4,3,9);
ax.RPCH = subplot(4,3,6);
ax.CabTrp1a = subplot(4,3,12);

preps = categories(alldata.experiment_idx);
preps = preps(sidx);
cats = categories(idx);

C = colormaps.dcol(length(cats));

yoffset = 1;

set(ax.main,'XLim',[-2500 1000],'YLim',[-5 100])

r = rectangle(ax.main,'Position',[-600 -1 1.6e3 91],'FaceColor',[.85 .85 .85 ],'EdgeColor',[.85 .85 .85]);
r = rectangle(ax.main,'Position',[0 91 1e3 2],'FaceColor',[1 0 0  .25],'EdgeColor',[1 0 0  .25]);

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
        plot(ax.main,time_since_mod_on,yy,'Color',C(j,:),'LineWidth',4)

        % now what about single pts? 
        yy1 = circshift(yy,1);
        yy2 = circshift(yy,-1);

        isolated_pts = ~isnan(yy) & isnan(yy1) & isnan(yy2);

        plot(ax.main,time_since_mod_on(isolated_pts),yy(isolated_pts),'.','MarkerSize',10,'Color',C(j,:),'LineStyle','none')


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
    lh(i) = plot(ax.main,NaN,NaN,'.','MarkerSize',50,'DisplayName',cats{i},'Color',C(i,:));
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

text(ax.main,-2500,92,'control','FontSize',20,'Color',[0 0 0]);
text(ax.main,-600,92,'decentralized','FontSize',20,'Color',[.6 .6 .6]);
text(ax.main,100,94.5,'+modulator','FontSize',24,'Color',[1 .5 .5]);


% wordcloud of normal
axes(ax.normal)
w = wordcloud(gcf,idx(~alldata.decentralized));
w.SizePower = 1;

% color them correctly
cidx = [];
for i = length(w.WordData):-1:1
    cidx(i) = find(strcmp(w.WordData(i),cats));
end
w.Color = C(cidx,:);

w_normal = w;



% decentralized
axes(ax.decentralized)
w = wordcloud(gcf,idx(alldata.decentralized & alldata.time_since_mod_on < 0));
w.SizePower = 1;

% color them correctly
cidx = [];
for i = length(w.WordData):-1:1
    cidx(i) = find(strcmp(w.WordData(i),cats));
end
w.Color = C(cidx,:);


w_decentralized = w;

show_these = {'RPCH','oxotremorine','CabTrp1a'};
for j = 1:length(show_these)

    axes(ax.(show_these{j}))
    w(j) = wordcloud(gcf,idx(alldata.(show_these{j})>0));
    %w.SizePower = 1;

    % color them correctly
    cidx = [];
    for i = length(w(j).WordData):-1:1
        cidx(i) = find(strcmp(w(j).WordData(i),cats));
    end
    w(j).Color = C(cidx,:);
    w(j).Box = 'on';



end

ax.main.Position = [.02 .05 .6 .7];

figlib.pretty()
axis(ax.main,'off')



w(1).Position = [.75 .47 .2 .15];
w(2).Position = [.75 .25 .2 .15];
w(3).Position = [.75 .05 .2 .15];


a = annotation('textarrow');
a.Position = [0.7495   0.315  -0.024 0];


a = annotation('textarrow');
a.Position = [.75 .125 -.050 0];


a = annotation('textarrow');
a.Position = [.75 .542 -.07 0];




w_normal.Box = 'on';
w_decentralized.Box = 'on';

w_normal.Position = [.01 .75 .2 .15];
w_decentralized.Position = [.3 .75 .2 .15];


a = annotation('textarrow');
a.Position = [.04 .75 0 -.040];

a = annotation('textarrow');
a.Position = [.39 .75 0 -.040];

plot(ax.main,[-750 -650],[0 0],'k','LineWidth',4,'HandleVisibility','off')

axes(ax.main);
th = text(-800,-3,'100 s','FontSize',20);