% plot how prob of being in normal state changes
% for each prep



close all

init()


figure('outerposition',[300 300 1500 901],'PaperUnits','points','PaperSize',[1500 901]); hold on

clear ax

modnames = {'RPCH','proctolin','oxotremorine','serotonin'};

for i = 1:length(modnames)
	ax(i) = subplot(2,2,i); hold on


	% find all preps where this mod is used
	preps = unique(moddata.experiment_idx(moddata.(modnames{i}) > 0));
	preps = moddata.slice(ismember(moddata.experiment_idx,preps) & moddata.decentralized);


	if length(preps.mask) == 0
		continue
	end


	% only use the last 5 minutes before mod on
	% to ignore transient effects of decentralization
	LastFiveMinutes = @(data)  ((1:length(data.mask)) - find(data.(modnames{i}) > 0,1,'first') + 15 ) > 0;

	T = analysis.forEachPrep(preps,LastFiveMinutes);
	preps = preps.slice(T);


	% find the 


	P_decentralized = preps.probState(preps.(modnames{i})==0);
	P_mod = preps.probState(preps.(modnames{i})>0);


	Y = P_mod(:,1);
	Y = Y;
	plot(P_decentralized(:,1),Y,'ro')


	set(gca,'YLim',[0 1])
	plotlib.drawDiag;


end

figlib.pretty('FontSize',16)


return

figlib.saveall('Location',display.saveHere)
init()