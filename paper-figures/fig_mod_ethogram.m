
% this script makes an ethogram of all experiments, and wordclouds for differnet regions

init()

% unpack
idx = alldata.idx;
cats = categories(idx);
colors = display.colorscheme(cats);


close all
figure('outerposition',[300 300 1333 900],'PaperUnits','points','PaperSize',[1333 900]); hold on



% figure out the modulator used in each prep
modulator_used = sourcedata.modulatorUsedByPrep(moddata);

[~,sidx] = sort(lower(corelib.categorical2cell(modulator_used)));
sorted_mods = modulator_used(sidx);

clearvars ax


ax.control = subplot(1,4,1); hold on
set(ax.control,'XLim',[0 600]) % 10 minutes

ax.decentralized = subplot(1,4,2); hold on
set(ax.decentralized,'XLim',[-600 0]) % 10 minutes before and after mod addition

ax.modulator = subplot(1,4,3:4); hold on
set(ax.modulator,'XLim',[0 1200]) % 10 minutes before and after mod addition


axis(ax.control,'off')
axis(ax.decentralized,'off')
axis(ax.modulator,'off')

ax.control.Position = [.05 .05 .15 .73];
ax.decentralized.Position = [.21 .05 .15 .73];
ax.modulator.Position = [.37 .05 .3 .73];

ax.base = axes;
ax.base.Position = [0 0 1 1];
axis(ax.base,'off');
ax.base.XLim = [0 1];
ax.base.YLim = [0 1];

show_these = {'control','decentralized','RPCH','proctolin','oxotremorine'};

for i = 1:length(show_these)
    ax.tree.(show_these{i}) = axes;
    axis(ax.tree.(show_these{i}),'off')
end

ax.tree.control.Position = [.05 .85 .15 .11];
ax.tree.decentralized.Position = [.21 .85 .15 .11];
ax.tree.RPCH.Position = [.8 .56 .15 .11];
ax.tree.proctolin.Position = [.8 .39 .15 .11];
ax.tree.oxotremorine.Position = [.8 .24 .15 .11];



cats = corelib.categorical2cell(unique(idx));

yoffset = 1;

linepos = [];

return

for i = 1:length(data)

    prep = data(sidx(i)).experiment_idx(1);
    use_these = (alldata.experiment_idx == prep);
    decentralized = alldata.decentralized(use_these);
    time_since_mod_on = alldata.time_since_mod_on(use_these);

    % get states
    states = idx(use_these);

    y = time_since_mod_on*0 + yoffset;

    % plot 10 minutes of decentralized just before ANY neuromod is added
    display.plotStates(ax.decentralized, cats, states, time_since_mod_on, y);

    

    % plot neuromodulator at the highest concentration
    this_mod = alldata.(char(sorted_mods(i)))(use_these);
    a = find(this_mod == max(this_mod),1,'first');
    if  length(unique(this_mod)) > 2
        % cronin data with more than 1 conc
         display.plotStates(ax.modulator, cats, states,  time_since_mod_on -  time_since_mod_on(a), y);
    else
        % should be OK, just plot
        display.plotStates(ax.modulator, cats, states, time_since_mod_on, y);
    end


    % plot 10 minutes of control
    display.plotStates(ax.control, cats, states, time_since_mod_on - time_since_mod_on(1), y);

    if nanmax(data(sidx(i)).RPCH) > 0
        disp(data(sidx(i)).experiment_idx(1))
    end


    yoffset = yoffset + 1;

    if i < length(data)
        if sorted_mods(i) ~=  sorted_mods(i+1)
            plotlib.horzline(ax.control,yoffset + 1,'k:');
            plotlib.horzline(ax.decentralized,yoffset + 1,'k:');
            plotlib.horzline(ax.modulator,yoffset + 1,'k:');
            linepos = [linepos; yoffset+1];
            yoffset = yoffset + 3;

        end
    end


end


% plot control states
axes(ax.tree.control)
states = alldata.idx(alldata.decentralized == false);
display.mondrian(states,colors);

% plot decentralized
axes(ax.tree.decentralized)
states = alldata.idx(alldata.decentralized == true & alldata.time_since_mod_on < 0);
display.mondrian(states,colors);

% show treemaps for modulators
for j = 3:length(show_these)
    axes(ax.tree.(show_these{j}))
    states = alldata.idx(alldata.(show_these{j}) > 0);
    display.mondrian(states,colors);

end



% make fake plots for a legend
clear lh
for i = 1:length(cats)
    lh(i) = plot(ax.control,NaN,NaN,'.','MarkerSize',50,'DisplayName',cats{i},'Color',colors(cats{i}));
end


L = legend(lh);
L.NumColumns = 3;
L.Position = [0.55 0.84 0.4 0.15];


[~,temp] = unique(lower(corelib.categorical2cell(sorted_mods)));
umods = sorted_mods(temp);
linepos = [0; linepos] + diff([0; linepos; yoffset])/2;

for i = 1:length(umods)
    text(ax.decentralized,1.3e3,linepos(i),char(umods(i)),'HorizontalAlignment','left','FontSize',20)
end

r1 = rectangle(ax.base,'Position',[.205 .04 .47 .745],'FaceColor',[.85 .85 .85 ],'EdgeColor',[.85 .85 .85]);
uistack(r1,'bottom');
uistack(ax.base,'bottom')


r2 = rectangle(ax.base,'Position',[.37 .79 .305 .018],'FaceColor',[1 0 0  .25],'EdgeColor',[1 0 0  .25]);
uistack(r1,'bottom');




th = text(ax.base,0.1,.8,'control','FontSize',20,'Color',[0 0 0]);
th = text(ax.base,.23,.8,'decentralized','FontSize',20,'Color',[.6 .6 .6]);
th = text(ax.base,.4,.82,'+modulator','FontSize',24,'Color',[1 .5 .5]);

figlib.pretty('PlotLineWidth',1)



% clean up worksapce
clearvars -except alldata data p