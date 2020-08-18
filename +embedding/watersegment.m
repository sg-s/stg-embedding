% given a Nx2 array containing coordinates,
% applies a watershed segmentation to find "sub-clusters"
% so that we can show sub-occupancy nicely


function idx = watersegment(R)

assert(isnumeric(R),'Expected a double argument')

nbins = 130; % increasing this will result in more clusters
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

