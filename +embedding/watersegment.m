% given a Nx2 array containing coordinates,
% applies a watershed segmentation to find "sub-clusters"
% so that we can show sub-occupancy nicely


function idx = watersegment(R)

assert(isnumeric(R),'Expected a double argument')

nbins = 200; % increasing this will result in more clusters
blur_radius = 1;



[I,x,y] = histcounts2(R(:,1),R(:,2),nbins);

top_cutoff = mean(I(I>0));

I(I>top_cutoff) = top_cutoff;

% opening = erosion + dilation 
I2 = imopen(I,strel('disk',blur_radius));
I2 = I2 + I;

W = (watershed(max(I2(:)) -I2));

% the watershed returns a labelled matrix,
% but ridge lines are indicated with a zero
% we also want a label for the ridgelines. How do we get that?
% we can't use regionfill because it makes up new values
% instead we dilate, because image dilation recognises the 
% special value of 0

W2 = imdilate(W,strel('disk',1));
W(W==0) = W2(W==0);


% re-color original points by watershed segmentation
xi = discretize(R(:,1),x);
yi = discretize(R(:,2),y);

idx = NaN*R(:,1);
for i = 1:length(idx)
	idx(i) = W(xi(i),yi(i));
end

