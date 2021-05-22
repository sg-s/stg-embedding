% This script makes a figure of the map
% assuming it exists, and shows illustrative examples from
% each class 

close all
init

% unpack
idx = alldata.idx;
cats = categories(idx);
colors = display.colorscheme(cats);


LP_color = color.aqua('red');
PD_color = color.aqua('indigo');


figure('outerposition',[300 300 2000 999],'PaperUnits','points','PaperSize',[2000 999]); hold on


n_rows = length(cats)/2;
pidx = 1;
for i = 1:3
    for j = 1:n_rows
        ax.examples(pidx) = subplot(n_rows,3,pidx); hold on
        
        set(ax.examples(pidx),'YLim',[-.5 5.5],'XLim',[-.5 10])
        pidx = pidx + 1;
    end
end

ax.main = subplot(1,3,1); hold on
axis off
ax.examples = ax.examples(isvalid(ax.examples));


plot(ax.main,R(:,1),R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)
for i = length(cats):-1:1
    plot(ax.main,R(idx==cats{i},1),R(idx==cats{i},2),'.','Color',colors(cats{i}),'MarkerSize',10)
    
end
axis square


show_these_states = dictionary;
show_these_states.regular = {'50360b4df7c9d467950f9e5f15d35fb3','9efa9bfe8dd8b760407f5026fadbb228'};
show_these_states.('aberrant-spikes') = {'ef8a52bcb903ca14196247516343a814','5280b059a4b7e1c07c2b4cf551ae5444'};
show_these_states.irregular = {'6ac42ae912fa39a72934180f2dfb6f2a','7e31784000fc3d342c0613b4f85021f2'};
show_these_states.('irregular-bursting') = {'9d4e73c58fd4041d5ae1121e9d9f72b9','39f4b6d8681795e877d858e1c6d758d9'};
show_these_states.('LP-weak-skipped') = {'0d524d187e10052bef1fe6381ca4b90d','58ade150c5f148471548fedcd8771fae'};
show_these_states.('PD-weak-skipped') = {'348084f45db82a4562bc64e261458d31','04a08d2879f86c9487cad1938705fc68'};
show_these_states.('LP-silent-PD-bursting') = {'a4aeb01d81c31f51f46b9e424b02c447','5eabf649107f7dc40b4c2feb869143fa'};
show_these_states.('PD-silent') = {'8c2382765f32dde0d2afe95008893959','4e8f00b1e593425abc635051b56036d5'};
show_these_states.('silent') = {'b45625f4f424657001b0b42d3cebd833','b45625f4f424657001b0b42d3cebd833'};
show_these_states.('sparse-irregular') = {'4ce353693ce6a5a03e9ba25a622f5de2','0db8049d9bc4cd818a54dc2c56bf6cd0'};
show_these_states.('LP-silent') = {'5ae27186d2271445a77c555b96917225', '1f8e7f07142a9cb590fe161f60bd1057'
};
show_these_states.('PD-silent-LP-bursting') = {'fb74e847b4e8971c1d3228556a61f8b6', '764dcce923afddf54688aa13489373cd'
};


% sort cats by likelihood
[~,sidx] = sort(histcounts(alldata.idx),'descend');
cats = cats(sidx);

for i = 1:length(ax.examples)
    axes(ax.examples(i))

    show_these = show_these_states.(cats{i});

    Y = 0;

    for j = 1:2

        show_this = find(strcmp(hashes.alldata,show_these{j}));


        show_this = show_this(1);
        
        PD = alldata.PD(show_this,:);
        LP = alldata.LP(show_this,:);
        offset = nanmin([LP(:); PD(:)]);
        PD = PD - offset;
        LP = LP - offset;
        neurolib.raster(PD,'deltat',1,'center',false,'yoffset',Y,'LineWidth',1,'Color',PD_color)
        neurolib.raster(LP,'deltat',1,'center',false,'yoffset',Y+1,'Color',LP_color,'LineWidth',1)
        

        Y = Y + 3;

    end

    title([char(idx(show_this)) ' (n=' mat2str(sum(idx==cats{i})) ')'],'FontWeight','normal')

    

    ax.examples(i).YTick = [];
    ax.examples(i).XTick = [];
    axis(ax.examples(i),'on')
    this_color = colors(idx(show_this));
    plotlib.vertline(ax.examples(i),-.45,'Color',this_color,'LineWidth',10);
    axlib.banding('ax',ax.examples(i),'spacing',2.75,'start',-.25)

end


figlib.pretty('LineWidth',1)

for i = 1:length(ax.examples)
    ax.examples(i).Box = 'off';
    ax.examples(i).XColor = 'w';
end


axlib.move(ax.examples,'right',.05)
axlib.move(ax.examples(1:2:end),'right',.05)

ax.main.Position = [.06 .1 .4 .8];
ax.examples(1).YTick = [.5 1.5 3.5 4.5];
ax.examples(1).YTickLabel = '';

th = text(ax.examples(1),-1.5, .5, 'PD');
th.FontSize = 16;
th.Color = PD_color;

th = text(ax.examples(1),-1.5, 1.5, 'LP');
th.FontSize = 16;
th.Color = LP_color;

drawnow()

axlib.label(ax.main,'a','FontSize',36,'XOffset',.01);
h = axlib.label(ax.examples(1),'b','FontSize',36,'XOffset',-.025,'YOffset',-.01);

plot(ax.examples(end),[9 10],[-.5 -.5],'LineWidth',4,'Color','k')
th =text(ax.examples(end),9.2,-1.1,'1s');
th.FontSize = 20;

figlib.saveall('Location',display.saveHere)



% clean up workspace
init()