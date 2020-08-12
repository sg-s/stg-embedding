


show_this = [2 3 4 5 6 7];

fn = fieldnames(p);

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

for i = 1:length(show_this)

	subplot(2,3,i); hold on

	C = VectorizedData(:,show_this(i));

	scatter(R(:,1),R(:,2),23,C,'filled')

	colorbar
	axis off
	colormap(colormaps.redula)

	title(fn{show_this(i)},'interpreter','none')

end


figlib.pretty