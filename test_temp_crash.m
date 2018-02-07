%%
% In this document, I try to embed data from Leandro's temperature pertubrtion 
% simulations 

data_root = '~/Google Drive/leandro-temp-data';
all_folders = dir([data_root oss 'set_*']);
all_temp = 10:0.125:30; 


AB_spikes = sparse(20e3,length(all_temp)*6);
LP_spikes = sparse(20e3,length(all_temp)*6);
PY_spikes = sparse(20e3,length(all_temp)*6);
temperature = NaN(length(all_temp)*6,1);
data_set = NaN(length(all_temp)*6,1);



idx = 0;

for i = 1:length(all_folders)

	for j = 1:length(all_temp)

		textbar(j,length(all_temp))

		hash = all_folders(i).name(5:end);

		if all_temp(j) == round(all_temp(j))
			temp_str = [mat2str(all_temp(j)) '.0'];
		else
			temp_str = mat2str(all_temp(j));
		end


		clear AB LP PY
		AB = load(joinPath(data_root,all_folders(i).name,['q10s-' hash '.AB.temp.' temp_str '.txt']));
		LP = load(joinPath(data_root,all_folders(i).name,['q10s-' hash '.LP.temp.' temp_str '.txt']));
		PY = load(joinPath(data_root,all_folders(i).name,['q10s-' hash '.PY.temp.' temp_str '.txt']));


		AB = round(AB);
		AB(AB==0) = 1;

		LP = round(LP);
		LP(LP==0) = 1;

		PY = round(PY);
		PY(PY==0) = 1;
			

		% load into matrix 
		for k = 1:6

			idx = idx + 1;

			a = (k-1)*20e3; z = k*20e3;
			this_AB = AB(AB>a&AB<z); this_AB = this_AB - a;
			this_LP = LP(LP>a&LP<z); this_LP = this_LP - a;
			this_PY = PY(PY>a&PY<z); this_PY = this_PY - a;

			AB_spikes(nonnans(this_AB),idx) = 1;
			LP_spikes(nonnans(this_LP),idx) = 1;
			PY_spikes(nonnans(this_PY),idx) = 1;
			temperature(idx) = all_temp(j);
			data_set(idx) = i;
		end

	end


end


return


% convert these spike times into a high dimensional vectors 

% X = NaN(size(AB_spikes,2),17);


% parfor i = 1:size(X,1)


% 	% create the spike->pseudovariable filter
% 	p = struct('tau',100,'n',1,'A',1);

% 	mean_isi = mean(diff(find(AB_spikes(:,i))));
% 	K = normpdf(-2e3:2e3,0,mean_isi);

% 	AB = fastFilter(K,1,full(AB_spikes(:,i)));

% 	mean_isi = mean(diff(find(LP_spikes(:,i))));
% 	K = normpdf(-2e3:2e3,0,mean_isi);
% 	LP = fastFilter(K,1,full(LP_spikes(:,i)));

% 	mean_isi = mean(diff(find(PY_spikes(:,i))));
% 	K = normpdf(-2e3:2e3,0,mean_isi);
% 	PY = fastFilter(K,1,full(PY_spikes(:,i)));

% 	[theta_AB,~,m_AB] = phasify(AB);
% 	[theta_LP,~,m_LP] = phasify(LP);
% 	[theta_PY,~,m_PY] = phasify(PY);


% 	% chuck the first half of the trace
% 	theta_AB(1:length(theta_AB)/2) = [];
% 	theta_LP(1:length(theta_LP)/2) = [];
% 	theta_PY(1:length(theta_PY)/2) = [];

% 	pd_AB_LP = 2*pi*(finddelay(theta_AB,theta_LP)/m_AB.T);
% 	pd_AB_PY = 2*pi*(finddelay(theta_AB,theta_PY)/m_AB.T);

% 	if pd_AB_LP < 0
% 		pd_AB_LP = pd_AB_LP + 2*pi;
% 	end


% 	if pd_AB_PY < 0
% 		pd_AB_PY = pd_AB_PY + 2*pi;
% 	end

% 	X(i,:) = [mean(AB) m_AB.T m_AB.circ_dev nanmean(m_AB.mean_rho) nanmean(m_AB.std_rho) nanmean(LP) m_LP.T m_LP.circ_dev nanmean(m_LP.mean_rho) nanmean(m_LP.std_rho) nanmean(PY) m_PY.T m_PY.circ_dev nanmean(m_PY.mean_rho) nanmean(m_PY.std_rho) pd_AB_LP pd_AB_PY];

% end






X(isnan(X)) = -1;

% what if we nromalize all the data
for i = 1:size(X,2)
	X(:,i) = X(:,i)/nanmean(X(:,i));
end

R = mctsne(X',3e3,300);


c = parula(100);

cidx = temperature;
cidx = cidx - min(cidx);
cidx = cidx/max(cidx);
cidx = ceil(cidx*99) + 1;

C = c(cidx,:);

figure('outerposition',[0 0 999 801],'PaperUnits','points','PaperSize',[999 801]); hold on

% plot lines
ud = unique(data_set);

for i = 1:length(ud)

	%

	scatter(R(1,data_set == ud(i)),R(2,data_set == ud(i)),128,C(data_set == ud(i),:),'filled','Marker','o');

	%plot(R(1,:),R(2,:),'o','Color',[.5 .5 .5])
end

colorbar
caxis([10 30])

prettyFig();


% pikc and example
example_id = 3;


% plot 22*C and 23C 
scatter(R(1,data_set == example_id & temperature == 27),R(2,data_set == example_id & temperature == 27),128,[1 0 0],'filled','Marker','o');

scatter(R(1,data_set == example_id & temperature == 22),R(2,data_set == example_id & temperature == 22),128,[0 0 1],'filled','Marker','o');


1
% show an example
all_temp = unique(temperature);

for i = 1:length(all_temp)
	scatter(R(1,data_set == example_id & temperature == all_temp(i)),R(2,data_set == example_id & temperature == all_temp(i)),128,C(data_set == example_id & temperature == all_temp(i),:),'filled','Marker','o');
	pause(.01)
	title(oval(all_temp(i)))
	drawnow
end




if being_published
	snapnow
	delete(gcf)
end
