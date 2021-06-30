
close all

init()


figure('outerposition',[300 300 1000 1222],'PaperUnits','points','PaperSize',[1000 1222]); hold on

cats = categories(alldata.idx);
regular_idx = find(strcmp(cats,'regular'));
modnames = {'RPCH','proctolin','oxotremorine','serotonin'};


n_mod = length(modnames);
for i = n_mod*3:-1:1
	ax(i) = subplot(4,n_mod,i); hold on
end



L = display.stateLegend(ax(n_mod),cats,'NumColumns',3);


delete(ax(2:n_mod-1))
L.Position = [.38 .79 .45 .15];


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
title(ax(1),{'decentralized',['(n = ' mat2str(length(decentralized.idx)) ', N = ' mat2str(n_crabs) ') ' ]},'FontWeight','normal')

ConditionalProb = struct;

Table = table(round(mean(decP)',2),'VariableNames',{'decentralized'},'RowNames',cats);

for i = 1:length(modnames)
	
	M = modnames{i};

	% find all preps where this mod is used
	preps = unique(moddata.experiment_idx(moddata.(M) > 0));
	preps = moddata.slice(ismember(moddata.experiment_idx,preps) & moddata.decentralized & moddata.(M)>=5e-7);



	P = preps.probState();


	axes(ax(i+n_mod))



	p = display.mondrian(nanmean(P),cats);
	display.boxPatch(p(regular_idx));
	n_crabs = length(unique(preps.experiment_idx));
	title(ax(i+n_mod),{['+' M],['(n = ' mat2str(length(preps.idx)) ', N = ' mat2str(n_crabs) ') ' ]},'FontWeight','normal')


	% compare to decentralized in the same preps with no mod
	dec = moddata.slice(ismember(moddata.experiment_idx,unique(preps.experiment_idx)) & moddata.modulator == 0);

	T = analysis.forEachPrep(dec,FirstHalf);
	dec = dec.slice(T);

	% add to table
	Table = [Table table(round(mean(P)',2),'VariableNames',{M},'RowNames',cats)];

	decP = dec.probState();

	p_value = statlib.pairedPermutationTest(P(:,regular_idx),decP(:,regular_idx),1e3)


	delta_normal = 100*((mean(P(:,regular_idx)) - mean(decP(:,regular_idx)))/mean(decP(:,regular_idx)));
	txt = [mat2str(round(delta_normal)) '%'];
	if delta_normal > 0
		txt = ['+' txt];
	end
	y = p(regular_idx).Vertices(2,2)/2;
	x = p(regular_idx).Vertices(3,1)/2;
	th = text(ax(n_mod+i),x,y,txt);
	th.HorizontalAlignment = 'center';
	th.VerticalAlignment = 'middle';
	th.Color = 'w';
	th.FontWeight =  'bold';
	


	[J.(M),N.(M)] = analysis.computeTransitionMatrix(preps.idx, preps.time_offset);

	axes(ax(i+n_mod*2))


	if strcmp(M,'serotonin')
		this = J.(M)(regular_idx,:);
		n = N.(M)(regular_idx,:);
	else
		this = J.(M)(:,regular_idx);
		n = N.(M)(:,regular_idx);
	end
	this(regular_idx) = 0;
	n(regular_idx) = 0;

	ConditionalProb.(M) = n;

	p = display.mondrian(this,cats);
	th = title(['(' mat2str(sum(n)) ' transitions)']);
	th.Position = [-.15 .5];
	th.FontWeight = 'normal';




end


figlib.pretty('FontSize',16)

arrow_length = .07;
for i = 1:n_mod
	a = annotation('arrow',[.5175 .2566],[.04 .07]);
	x = ax(i+n_mod*2).Position(1) + ax(i+8).Position(3)/2;
	y = ax(i+n_mod*2).Position(2) + ax(i+8).Position(4);
	a.Position = [x y-.005 0 arrow_length];
	a.LineWidth = 2;
	if i == n_mod
		a.Position(2) = y + arrow_length;
		a.Position(4) = -arrow_length;
	end
end






axlib.label(ax(1),'a','FontSize',24,'XOffset',-.01)
axlib.label(ax(n_mod+1),'b','FontSize',24,'XOffset',-.01)
axlib.label(ax(2*n_mod+1),'c','FontSize',24,'XOffset',-.01)

figlib.saveall('Location',display.saveHere,'Format','pdf')

display.trimImage([mfilename '_1.pdf']);

init()