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
show_these_states.normal = {'daf06c66a4b297bd14e82f7589e7cab6','eb02c69951660235217d56152865b7a3'};
show_these_states.('aberrant-spikes') = {'44e25b9221f776de2e52bd1bae8e0eab','5b7a4f3f010cf7e12782e72d2628bf8c'};
show_these_states.('interrupted-bursting') = {'1ccc6ca1b96bf1e5b1642bc71ed907c7','6f886cb836f53c4529807dcf706436d1'};
show_these_states.irregular = {'0e3b65f24ab42bab86564ef693c4cfb5','ad3ee389335fc4b365fed7b2f531610e'};
show_these_states.('irregular-bursting') = {'84e3bad1b986fd40e3103e0b2c5261c3','e66fdc5e7121689b0c06f7dc6bb1ba2c'};
show_these_states.('LP-weak-skipped') = {'c8dd020a7e6c3633291c1ae6ba19264b','5b41adb21f64ab8cdc0414a266539aa2'};
show_these_states.('PD-weak-skipped') = {'07a41b92d6745e75680e115a395b539c','16729e1f5824028e23f5495d1322f108'};
show_these_states.('PD-skipped-bursts') = {'28db2f63a24284aa4e29742b856a683b','6011b078db9c37207cb56dac3a153400'};
show_these_states.('LP-silent-PD-bursting') = {'d2ec80d287ea0673b2991d147ab61101','f197e54d593c546fb74b6c5e6d97a403'};
show_these_states.('silent') = {'b45625f4f424657001b0b42d3cebd833','b45625f4f424657001b0b42d3cebd833'};




fn = show_these_states.keys;

for i = 1:length(ax.examples)
    axes(ax.examples(i))

    show_these = show_these_states.(fn{i});

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