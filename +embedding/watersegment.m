
function idx = watersegment(alldata)

R = double(alldata.R);

nbins = 100;
blur_radius = 1;
max_value = 2;



[I,x,y] = histcounts2(R(:,1),R(:,2),nbins);

I(I>max_value) = max_value;

% opening = erosion + dilation 
I2 = imopen(I,strel('disk',blur_radius));
I2 = I2 + I;

W = (watershed(max(I2(:)) -I2));

% re-color original points by watershed segmentation
xi = discretize(R(:,1),x);
yi = discretize(R(:,2),y);

idx = NaN*R(:,1);
for i = 1:length(idx)
	idx(i) = W(xi(i),yi(i));
end

return




b_noise = .2;

cats = categories(alldata.idx);
colors = display.colorscheme(cats);

for i = 1:max(idx)
	this_x = R(idx==i,1);
	this_y = R(idx==i,2);

	this_x = 	repmat(this_x,10,1) + b_noise*randn(length(this_x)*10,1);
	this_y = 	repmat(this_y,10,1) + b_noise*randn(length(this_y)*10,1);

	b = boundary(this_x,this_y);
	
		this_color = colors(alldata.idx(find(idx==i,1,'first')));
	fill(this_x(b),this_y(b),brighten(this_color,.8),'EdgeColor',this_color)



	plot(R(idx==i,1),R(idx==i,2),'.','Color','k')
end

% J = embedding.computeTransitionMatrix(categorical(idx));

% % only retain top two links for each node
% % 
% for i = 1:length(J)
% 	sJ = sort(J(:,i));
% 	J(J(:,i) < sJ(end-1),i) = 0;
% end

% p = plot(digraph(J));
% p.Parent = gca;
% for i = 1:max(idx)
% 	p.XData(i) = mean(R(idx==i,1));
% 	p.YData(i) = mean(R(idx==i,2));
% end


n_preps = NaN(max(idx),1);
n_pts_per_cluster = NaN(max(idx),1);
for i = 1:max(idx)
	n_preps(i) = length(unique(alldata.experiment_idx(idx==i)));
	n_pts_per_cluster(i) = length((alldata.experiment_idx(idx==i)));
end


subplot(2,2,3); hold on
plot(n_preps,n_pts_per_cluster,'ko')
set(gca,'XScale','log','YScale','log')


% plot clusters and colour them by idisynracry 
subplot(2,2,4); hold on
for i = 1:max(idx)
	if n_preps(i) == 1
		plot(R(idx==i,1),R(idx==i,2),'.','Color',[1 0 0]);
	elseif n_preps(i) == 2
		plot(R(idx==i,1),R(idx==i,2),'.','Color',[ 0.9882    0.4353    0.0118]);
	elseif n_preps(i) < 5
		plot(R(idx==i,1),R(idx==i,2),'.','Color',[0.9882    0.7922    0.0118]);
	else
		plot(R(idx==i,1),R(idx==i,2),'.','Color',[.8 .8 .8]);
	end
end
