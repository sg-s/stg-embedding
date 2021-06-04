function th = plotVariabilityBeforeTransition(CV,CV0,ax,time)

arguments
	CV struct
	CV0 struct
	ax struct
	time (:,1) double
end


things_to_measure = fieldnames(CV);

colors = display.colorscheme(NaN);

for j = 1:length(things_to_measure)
	thing = things_to_measure{j};



	% [~,TF] = rmoutliers(CV.(thing)(:,1));
	% CV.(thing)(TF,:) = NaN;

	[~,TF] = rmoutliers(CV.(thing),'quartiles');
	CV.(thing)(TF,:) = NaN;


	% % compute p using pairedpermutation test
	p = zeros(size(CV.(thing),2),1);
	for k = 1:length(p)
		p(k) = statlib.pairedPermutationTest(CV.(thing)(:,k),CV0.(thing));
		if nanmean(CV.(thing)(:,k)) < nanmean(CV0.(thing))
			p(k) = NaN;
		end
	end

	

	if any(strfind(thing,'PD'))
		Color = colors.PD;
	else
		Color = colors.LP;
	end

	plotlib.barWithErrorStar(time,nanmean(CV.(thing)),nanstd(CV.(thing)),p<.05/length(p),'Color',Color,'offset',.2,'ax',ax.(thing));

	% does variability increase with time before transition? 
	[rho,p] = statlib.correlation(time,nanmean(CV.(thing)),'Type','spearman');

	th(j) = text(ax.(thing),-190,.1,['\rho=' mat2str(rho,2) ', p=' mat2str(p,2)]);
	th(j).FontSize = 20;
	ax.(thing).XTick = sort(time(1:2:end));
end
