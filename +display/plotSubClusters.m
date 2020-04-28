function fh = plotSubClusters(ax,alldata,b_noise,sub_idx)

b_noise = .2;

R = double(alldata.R);

cats = categories(alldata.idx);
colors = display.colorscheme(cats);

for i = 1:max(sub_idx)
	this_x = R(sub_idx==i,1);
	this_y = R(sub_idx==i,2);

	this_x = 	repmat(this_x,10,1) + b_noise*randn(length(this_x)*10,1);
	this_y = 	repmat(this_y,10,1) + b_noise*randn(length(this_y)*10,1);

	b = boundary(this_x,this_y);
	
	this_color = colors(alldata.idx(find(sub_idx==i,1,'first')));
	fh(i) = fill(this_x(b),this_y(b),this_color,'EdgeColor',this_color,'LineWidth',1);
	fh(i).FaceAlpha = .1;
	fh(i).EdgeAlpha = .2;
end
