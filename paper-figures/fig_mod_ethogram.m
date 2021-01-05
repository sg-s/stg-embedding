
% this script makes an ethogram of all experiments, and mondrian plots of the differnet cases

close all
init()

% unpack
idx = moddata.idx;
cats = categories(idx);
colors = display.colorscheme(cats);



figure('outerposition',[30 30 1111 1233],'PaperUnits','points','PaperSize',[1111 1233]); hold on



% figure out the modulator used in each prep
[modulator_used, unique_preps] = sourcedata.modulatorUsedByPrep(moddata);

[~,sidx] = sort(lower(corelib.categorical2cell(modulator_used)));
sorted_mods = modulator_used(sidx);
unique_preps = unique_preps(sidx);

clearvars ax


ax.control = subplot(1,4,1); hold on
set(ax.control,'XLim',[-600 0]) % 10 minutes

ax.decentralized = subplot(1,4,2); hold on
set(ax.decentralized,'XLim',[-600 0]) % 10 minutes before modulator addition

ax.modulator = subplot(1,4,3:4); hold on
set(ax.modulator,'XLim',[0 1200]) % 20 minutes after mod addition


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
ax.tree.RPCH.Position = [.8 .61 .15 .11];
ax.tree.proctolin.Position = [.8 .44 .15 .11];
ax.tree.oxotremorine.Position = [.8 .29 .15 .11];



cats = corelib.categorical2cell(unique(idx));

yoffset = 1;

linepos = [];

for i = 1:length(unique_preps)

    prep = moddata.slice(moddata.experiment_idx == unique_preps(i));

    % if yoffset == 137
    %     keyboard
    % end

    % plot modulator
    time = analysis.timeSinceModOn(prep);

    display.plotStates(ax.modulator, prep.idx, time, yoffset);


    % plot decentralized
    % plot the last possible bits we have for decentralized data
    time = analysis.timeSinceDecentralization(prep);
    time(isinf(time)) = NaN;
    time = time - max(time);


    display.plotStates(ax.decentralized, prep.idx, time, yoffset);
    
    % plot control 
    % we're going to cheat a little and relax the restriction on using
    % the strict definition of time and instead plot everything we have
    % this should be OK
    idx = prep.idx(1:find(prep.decentralized,1,'first')-1);
    time = (1:length(idx))*20;
    time = time - time(end);
    display.plotStates(ax.control, idx, time, yoffset);
    



    yoffset = yoffset + 1;

    if i < length(unique_preps)
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
states = moddata.idx(moddata.decentralized == false);
display.mondrian(states,colors);



% plot decentralized
axes(ax.tree.decentralized)
states = moddata.idx(moddata.decentralized == true & moddata.modulator == 0);
display.mondrian(states,colors);



% show treemaps for modulators
for j = 3:length(show_these)
    axes(ax.tree.(show_these{j}))
    states = moddata.idx(moddata.(show_these{j}) > 0);
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
    th(i) = text(ax.decentralized,1.3e3,linepos(i),char(umods(i)),'HorizontalAlignment','left','FontSize',20);
end

r1 = rectangle(ax.base,'Position',[.205 .04 .47 .745],'FaceColor',[.85 .85 .85 ],'EdgeColor',[.85 .85 .85]);
uistack(r1,'bottom');
uistack(ax.base,'bottom')


r2 = rectangle(ax.base,'Position',[.37 .79 .305 .018],'FaceColor',[1 0 0  .25],'EdgeColor',[1 0 0  .25]);
uistack(r1,'bottom');




text(ax.base,0.1,.8,'control','FontSize',20,'Color',[0 0 0]);
text(ax.base,.23,.8,'decentralized','FontSize',20,'Color',[.6 .6 .6]);
text(ax.base,.4,.82,'+modulator','FontSize',24,'Color',[1 .5 .5]);

figlib.pretty('PlotLineWidth',1)


% align treemaps to text labels
align_these = {'RPCH','proctolin','oxotremorine'};
for i = 1:length(align_these)
    ax.tree.(align_these{i}).Position(2) = (th(umods == align_these{i}).Position(2)/yoffset)*ax.modulator.Position(4);
end

figlib.saveall('Location',display.saveHere)



% clean up
init()