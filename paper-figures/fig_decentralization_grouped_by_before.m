% this figure tries to understand what causes
% variability in decentralization responses
% by grouping data 

close all
init()

time_since_decentralization = analysis.timeSinceDecentralization(decdata);
all_preps = unique(decdata.experiment_idx);


cats = categories(decdata.idx);


figure('outerposition',[300 300 555 1222],'PaperUnits','points','PaperSize',[555 1222]); hold on

for i = 1:6
	ax(i) = subplot(3,2,i); hold on
	view([90 -90])
	axis off
end

axes(ax(1))
display.mondrian(decdata.idx(time_since_decentralization < 0 & time_since_decentralization > -600),cats)



before_states = {'regular','PD-weak-skipped','LP-weak-skipped'};

for j = 1:length(before_states)
	% find preps that were mostly in this state before decentralization
	use_this = false(length(decdata.idx),1);
	for i = 1:length(all_preps)
		if mode(decdata.idx(decdata.experiment_idx == all_preps(i) & time_since_decentralization < 0 & time_since_decentralization > -600)) == before_states{j}

			use_this(decdata.experiment_idx == all_preps(i)) = true;

		end
	end

	N = length(unique(decdata.experiment_idx(use_this)))

	axes(ax(j+1))
	display.mondrian(decdata.idx(time_since_decentralization > 0 & time_since_decentralization < 600 & use_this),cats)
	title(['N = ' mat2str(N)])
	view([-90 90])

end

% show all together, after
axes(ax(end))
display.mondrian(decdata.idx(time_since_decentralization > 0 & time_since_decentralization < 600 ),cats)
view([-90 90])


figlib.pretty()

% cleanup
figlib.saveall('Location',display.saveHere)

init()