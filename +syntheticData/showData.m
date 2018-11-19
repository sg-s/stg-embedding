function showData()

allfiles = dir('*.mat');


for i = 1:length(allfiles)

	load(allfiles(i).name)




	figure('outerposition',[300 300 900 1001],'PaperUnits','points','PaperSize',[900 1001]); hold on

	a = 200e4;
	z = a + 10e4;

	for j = 1:10
		subplot(10,1,j); hold on
		title(['T=' oval(10+j*2)])


		these_spikes = all_spikes;

		for k = 1:3
			these_spikes(these_spikes(:,k)<a | these_spikes(:,k)>z,k) = NaN;
		end
		raster(these_spikes(:,1),these_spikes(:,2),these_spikes(:,3))
		drawnow


		a = a + 200e4;
		z = a + 10e4;

	end

end

