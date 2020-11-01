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

pidx = 1;
for i = 1:3
    for j = 1:5
        ax.examples(pidx) = subplot(5,3,pidx); hold on
        
        set(ax.examples(pidx),'YLim',[-.01 6.01],'XLim',[-.5 10])
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
show_these_states.normal = {'903cb5a8f5433a52cc397f09cb7ffd64','fddcf31e6a6d4e9087b3495e3aa9f586'};
show_these_states.('aberrant-spikes') = {'d837ae2690b8588ce7ee2912bfccff4b','3ce2bbd03458b642691974508d5d9c0a'};
show_these_states.('interrupted-bursting') = {'d933191a837c1d6cb0073aff8d2e16c2','5d0b3af5ef7b5c05089812711f36006e'};
show_these_states.irregular = {'0e3b65f24ab42bab86564ef693c4cfb5','c7c77a5d614187c2e48e342442d62284'};
show_these_states.('irregular-bursting') = {'334208844ff04688cc5dfa580ef68a95','aaf0eec597ab2ed8f3825513b1958d92'};
show_these_states.('LP-weak-skipped') = {'6e554e9ffb2d580cffa8c3bc9bc7d505','d6c0c36a4428785597a3b321c41336c7'};
show_these_states.('PD-weak-skipped') = {'07a41b92d6745e75680e115a395b539c','16729e1f5824028e23f5495d1322f108'};
show_these_states.('LP-silent-PD-bursting') = {'a4aeb01d81c31f51f46b9e424b02c447','5eabf649107f7dc40b4c2feb869143fa'};
show_these_states.('PD-silent') = {'8c2382765f32dde0d2afe95008893959','4e8f00b1e593425abc635051b56036d5'};
show_these_states.('silent') = {'b45625f4f424657001b0b42d3cebd833','b45625f4f424657001b0b42d3cebd833'};




fn = show_these_states.keys;

for i = 1:length(ax.examples)
    axes(ax.examples(i))

    show_these = show_these_states.(fn{i});

    Y = 0;

    for j = 1:2

        show_this = find(strcmp(hashes.alldata,show_these{j}));

        if isempty(show_this)
            disp(fn{i})
        end

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

    title([char(idx(show_this)) ' (n=' mat2str(sum(idx==fn{i})) ')'],'FontWeight','normal')

    

    ax.examples(i).YTick = [];
    ax.examples(i).XTick = [];
    ax.examples(i).Box = 'on';
    axis(ax.examples(i),'on')
    this_color = colors(idx(show_this));
    plotlib.vertline(ax.examples(i),-.45,'Color',this_color,'LineWidth',10);
    ax.examples(i).Color = [.95 .95 .95];

end


figlib.pretty('LineWidth',1)


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

h = axlib.label(ax.main,'a','FontSize',36,'XOffset',.01);
h = axlib.label(ax.examples(1),'b','FontSize',36,'XOffset',-.025,'YOffset',-.01);

figlib.saveall('Location',display.saveHere)

% clean up workspace
init()