
close all

init()


figure('outerposition',[300 300 1111 1111],'PaperUnits','points','PaperSize',[1111 1111]); hold on



modnames = {'RPCH','CCAP','proctolin','oxotremorine','serotonin'};


n_mod = length(modnames);
for i = n_mod*3:-1:1
	ax(i) = subplot(3,n_mod,i); hold on
end


cats = categories(alldata.idx);
L = display.stateLegend(ax(n_mod),cats,3);


delete(ax(2:n_mod-1))
L.Position = [.38 .75 .45 .2];


% show decentralized only from preps with these mods
decentralized = unique(moddata.experiment_idx(moddata.RPCH > 0 | moddata.oxotremorine > 0 | moddata.proctolin > 0 | moddata.serotonin > 0));
decentralized = moddata.slice(ismember(moddata.experiment_idx,decentralized) & moddata.decentralized & moddata.modulator == 0);



FirstHalf = @(temp) (1:length(temp.mask)) - length(temp.mask)/2 > 0;
T = analysis.forEachPrep(decentralized,FirstHalf);
decentralized = decentralized.slice(T);


% compute probabilities of states in both conditions
decP = decentralized.probState();


axes(ax(1))

p = display.mondrian(nanmean(decP),cats);
n_crabs = length(unique(decentralized.experiment_idx));
T = length(decentralized.idx)*20/3600;
title(ax(1),{'decentralized',['(' mat2str(n_crabs) ' crabs, ' mat2str(T,2) ' hours) ' ]},'FontWeight','normal')


for i = 1:length(modnames)
	
	M = modnames{i};

	% find all preps where this mod is used
	preps = unique(moddata.experiment_idx(moddata.(M) > 0));
	preps = moddata.slice(ismember(moddata.experiment_idx,preps) & moddata.decentralized & moddata.(M)>=5e-7);



	P = preps.probState();


	axes(ax(i+n_mod))



	p = display.mondrian(nanmean(P),cats);
	display.boxPatch(p(1));
	n_crabs = length(unique(preps.experiment_idx));
	T = length(preps.idx)*20/3600;
	title(ax(i+n_mod),{['+' M],['(' mat2str(n_crabs) ' crabs, ' mat2str(T,2) ' hours) ' ]},'FontWeight','normal')

	delta_normal = 100*((mean(P(:,1)) - mean(decP(:,1)))/mean(decP(:,1)));
	txt = [mat2str(round(delta_normal)) '%'];
	if delta_normal > 0
		txt = ['+' txt];
	end
	y = p(1).Vertices(2,2)/2;
	x = p(1).Vertices(3,1)/2;
	th = text(ax(n_mod+i),x,y,txt);
	th.HorizontalAlignment = 'center';
	th.VerticalAlignment = 'middle';
	th.Color = 'w';
	


	N.(M) = analysis.computeTransitionMatrix(preps.idx, preps.time_offset);
	J.(M) = N.(M)/length(preps.idx);

	axes(ax(i+n_mod*2))


	if i == 4
		this = J.(M)(1,:);
		n = N.(M)(1,:);
	else
		this = J.(M)(:,1);
		n = N.(M)(:,1);
	end
	this(1) = 0;
	n(1) = 0;
	p = display.mondrian(this,cats);
	th = title(['(' mat2str(sum(n)) ' transitions)']);
	th.Position = [-.15 .5];
	th.FontWeight = 'normal';

end


arrow_length = .08;
for i = 1:n_mod
	a = annotation('arrow',[.5175 .2566],[.04 .07]);
	x = ax(i+n_mod*2).Position(1) + ax(i+8).Position(3)/2;
	y = ax(i+n_mod*2).Position(2) + ax(i+8).Position(4);
	a.Position = [x y 0 arrow_length];
	a.LineWidth = 2;
	if i == n_mod
		a.Position(2) = y + arrow_length;
		a.Position(4) = -arrow_length;
	end
end



figlib.pretty('FontSize',16)

axlib.label(ax(1),'a','FontSize',24,'XOffset',-.01)
axlib.label(ax(n_mod+1),'b','FontSize',24,'XOffset',-.01)
axlib.label(ax(2*n_mod+1),'c','FontSize',24,'XOffset',-.01)

return

figlib.saveall('Location',display.saveHere,'Format','pdf')
init()