% this figure shows dwell times of each state, in each condition

close all
init()


cats = categories(moddata.idx);
colors = display.colorscheme(cats);

modnames = {'RPCH','proctolin','oxotremorine','serotonin','CabTrp1a'};


decentralized  = moddata.decentralized & moddata.modulator == 0;


P = struct;
J = struct;


% decentralized transition rates
preps = moddata.slice(decentralized);
N.decentralized = analysis.computeTransitionMatrix(preps.idx, preps.time_offset);
J.decentralized = N.decentralized./length(preps.idx);




for modulator = List(modnames)
	disp(modulator)
	preps = unique(moddata.experiment_idx(moddata.(modulator) > 0));
	has_mod = ismember(moddata.experiment_idx,preps) & moddata.(modulator) > 0;
	no_mod = ismember(moddata.experiment_idx,preps) & moddata.(modulator) == 0 & moddata.decentralized;

	% measure actual differences
	preps = moddata.slice(has_mod);
	N.(modulator) = analysis.computeTransitionMatrix(preps.idx, preps.time_offset);
	J.(modulator) = N.(modulator)/length(preps.idx);


	actual_diff = J.(modulator) - J.decentralized;

	% estimate bootstrapped differences for shuffled data
	shuffled_diff = analysis.bootstrapTransitionMatrix(moddata,no_mod,has_mod);


	% now estimate p-values 
	P.(modulator) = sum(shuffled_diff > actual_diff,3)/size(shuffled_diff,3);

end



% plot transition rates without modulator vs. transition rates with modulator

figure('outerposition',[30 30 1400 901],'PaperUnits','points','PaperSize',[1400 901]); hold on


paired_plots = 1:2:9;
ranked_plots = 2:2:10;

for mi = 1:length(modnames)
	modulator = modnames{mi};

	subplot(3,4,paired_plots(mi)); hold on
	set(gca,'YScale','log','xscale','log')
	axis square
	set(gca,'XLim',[1e-3,1],'YLim',[1e-3,1],'YTick',[1e-3 1e-2 1e-1 1e0])
	plotlib.drawDiag(gca,'k:');
	title(['n = ' mat2str(sum(N.(modulator)(:))), ', ' mat2str(length(unique(moddata.experiment_idx(moddata.(modulator) > 0)))) ' crabs'],'FontWeight','normal')


	for i = 1:length(cats)
		for j = 1:length(cats)
			if P.(modulator)(i,j) < 1e-4
				

				x = J.decentralized(i,j);
				y = J.(modulator)(i,j);
				% plot this 
				plot(x*1.3,y,'Color',colors.(cats(j)),'Marker','o','MarkerFaceColor',colors.(cats(j)),'MarkerSize',10);
				plot(x,y,'Color',colors.(cats(i)),'Marker','>','MarkerFaceColor',colors.(cats(i)),'MarkerSize',10);

			end

		end
	end

	ylabel(['+' modulator] )

	if mi >= length(modnames)-1
		xlabel({'Decentralized','transition rate (s^{-1})'})
	end

	% also plot the delta transition rates for the significantly changed ones, sorted by effect size 
	actual_diff = J.(modulator) - J.decentralized;
	actual_diff(P.(modulator)>1e-4) = NaN;
	actual_diff = actual_diff./(J.decentralized + J.(modulator));
	actual_diff = actual_diff(:);
	[sorted_diffs,sidx] = sort(actual_diff,'descend','MissingPlacement','last');
	xoffset = 1;

	subplot(3,4,ranked_plots(mi)); hold on
	for i = 1:length(sorted_diffs)
		if xoffset > 11
			continue
		end
		[row,col] = ind2sub([length(cats),length(cats)],sidx(i));
		y = sorted_diffs(i);


		plot(xoffset+.3,y,'Color',colors.(cats(col)),'Marker','o','MarkerFaceColor',colors.(cats(col)),'MarkerSize',14);
		plot(xoffset,y,'Color',colors.(cats(row)),'Marker','>','MarkerFaceColor',colors.(cats(row)),'MarkerSize',14);
		xoffset = xoffset + 1;


	end
	set(gca,'XLim',[0 12],'XColor','w','YLim',[0 1])
	ylabel('\DeltaTransition rate (norm)')

end

figlib.label('XOffset',-.01)

axl = subplot(3,4,11:12);
lh = display.stateLegend(axl,cats);
figlib.pretty()

lh.Position = [.45 .05 .5 .23];

th = text(axl,0,0,'Transition rate with modulator (s^{-1})','Rotation',90,'FontSize',20);
th.Position = [-1.3 1];



% explain the markers
h2 = plot(axl,.4,.9,'o','MarkerFaceColor','w','MarkerEdgeColor','k','HandleVisibility','off','MarkerSize',24);
h = plot(axl,.36,.9,'>','MarkerFaceColor','w','MarkerEdgeColor','k','HandleVisibility','off','MarkerSize',24);
th = text(axl,.14,.91,'Initial state','FontSize',20);
th = text(axl,.44,.91,'Final state','FontSize',20);


figlib.saveall('Location',display.saveHere,'Format','png')



% clean up workspace
init()


