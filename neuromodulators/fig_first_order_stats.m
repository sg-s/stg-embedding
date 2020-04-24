% this figure shows dwell times of each state, in each condition

close all



ax = display.plotFirstOrderStats(idx(alldata.decentralized == false),colors)
ax.DwellTimes.Position = [.13 .15 .775 .33];
suptitle('Control')


ax = display.plotFirstOrderStats(idx(alldata.decentralized == true & alldata.time_since_mod_on<0),colors)
figlib.pretty('FontSize',15)
ax.DwellTimes.Position = [.13 .15 .775 .33];
suptitle('decentralized')

modnames = {'RPCH','proctolin','CabTrp1a','oxotremorine'};

for i = 1:length(modnames)
	ax = display.plotFirstOrderStats(idx(alldata.(modnames{i}) > 0),colors)
	ax.DwellTimes.Position = [.13 .15 .775 .33];
	suptitle(modnames{i})
end


