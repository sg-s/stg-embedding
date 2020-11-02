




figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

display.plotBackgroundLabels(gca,alldata, R)


experimenters = {'schneider','cronin','haddad','rosenbaum','tang'};


C = lines;
C(1,:)=  [];
C(5,:)=  [0 0 0];
for i = 1:length(experimenters)

	this = alldata.experimenter == experimenters{i} & alldata.idx == 'normal';
	plot(R(this,1),R(this,2),'.','Color',C(i,:))

end