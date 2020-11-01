% we look at the map and see what it tells us about baseline variability 



% find basedata in alldata
base = zeros(length(basedata.mask),1);
for i = 1:length(hashes.basedata)
	base(i) = find(strcmp(hashes.basedata{i},hashes.alldata),1,'first');
end






unique_preps = unique(basedata.experiment_idx);
figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

plot(R(:,1),R(:,2),'.','Color',[.9 .9 .9],'MarkerSize',30)


baseR = R(base,:);


all_areas = zeros(length(unique_preps),1) + Inf;
all_N = zeros(length(unique_preps),1);




for i = 1:length(unique_preps)
	this = basedata.experiment_idx == unique_preps(i) & basedata.idx == 'normal';

	all_N(i) = sum(this);
	if sum(this) < 30
		continue
	end

	X = baseR(this,:);

	% k = convhull(X);
	% all_areas(i) = area(polyshape(X(k,:)));


	all_areas(i) = sum(sqrt(sum(diff(X).^2,2)));

	all_areas(i) =  max(pdist(X));


end

 [~,idx]=sort(all_areas./all_N,'ascend');

 for i = 1:10
 	this = basedata.experiment_idx == unique_preps(idx(i)) & basedata.idx == 'normal';
 	X = baseR(this,:);

	k = convhull(X);
	plot(polyshape(X(k,:)));
 end