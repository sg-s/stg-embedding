
init()

close all

LP_color = color.aqua('red');
PD_color = color.aqua('indigo');
preps = unique(decdata.experiment_idx);

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

Y = 0;

for i = 2:3
	
	this = find(~decdata.decentralized & (decdata.experiment_idx == preps(i)) & decdata.idx == 'regular');
	this = this(1);


	PD = decdata.PD(this,:);
    LP = decdata.LP(this,:);
    offset = nanmin([LP(:); PD(:)]);
    PD = PD - offset;
    LP = LP - offset;
    neurolib.raster(PD,'deltat',1,'center',false,'yoffset',Y,'LineWidth',1,'Color',PD_color)
    Y = Y - 1;
    neurolib.raster(LP,'deltat',1,'center',false,'yoffset',Y,'LineWidth',1,'Color',LP_color)

    Y = Y - 2;

    % then show decentralized

    this = find(decdata.decentralized & (decdata.experiment_idx == preps(i)) &  decdata.idx == 'regular');
	this = this(end);


	PD = decdata.PD(this,:);
    LP = decdata.LP(this,:);
    offset = nanmin([LP(:); PD(:)]);
    PD = PD - offset;
    LP = LP - offset;
    neurolib.raster(PD,'deltat',1,'center',false,'yoffset',Y,'LineWidth',1,'Color',PD_color)
    Y = Y - 1;
    neurolib.raster(LP,'deltat',1,'center',false,'yoffset',Y,'LineWidth',1,'Color',LP_color)

    Y = Y - 2;

end

xlabel('Time (s)')

set(gca,'YTick',[-9, -6, -3, -0],'YLim',[-10.5 1.5])
set(gca,'YTickLabel',["Decentralized","Baseline","Decentralized","Baseline"])

figlib.pretty('LineWidth',1)


figlib.saveall('Location',display.saveHere,'Format','pdf')

% this init clears all the junk this script
init()