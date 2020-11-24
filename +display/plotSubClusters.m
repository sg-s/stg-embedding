function fh = plotSubClusters(ax,idx,R,sub_idx)

arguments

	ax (1,1) matlab.graphics.axis.Axes
	idx (:,1) categorical
	R (:,2) {mustBeNumeric}
	sub_idx

end

assert(~any(isundefined(idx)),'idx contains undefined states')


R = double(R);

b_noise = .1;

cats = categories(idx);
colors = display.colorscheme(cats);


for i = 1:max(sub_idx)
	this_x = R(sub_idx==i,1);
	this_y = R(sub_idx==i,2);

	this_x = 	repmat(this_x,10,1) + b_noise*randn(length(this_x)*10,1);
	this_y = 	repmat(this_y,10,1) + b_noise*randn(length(this_y)*10,1);

	b = boundary(this_x,this_y,1);
	
	this_color = colors(idx(find(sub_idx==i,1,'first')));
	fh(i) = fill(ax,this_x(b),this_y(b),this_color,'EdgeColor',this_color,'LineWidth',1);
	fh(i).FaceAlpha = .1;
	fh(i).EdgeAlpha = .2;
end
