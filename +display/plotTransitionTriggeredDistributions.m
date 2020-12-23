function plotTransitionTriggeredDistributions(data, state, N_before)

arguments

	data (1,1) embedding.DataStore
	state 
	N_before (1,1) double = 100
end


cats = categories(data.idx);


% find all transitions to the state
these_pts = find(circshift(data.idx ~= state,1) & data.idx == state);


state_matrix = categorical(NaN(N_before,length(these_pts)));
PD_f = zeros(N_before,length(these_pts));
LP_f = zeros(N_before,length(these_pts));
experiment_idx = categorical(NaN(length(these_pts),1));


for i = 1:length(these_pts)
	this = these_pts(i)-N_before:these_pts(i)-1;
	frame = data.idx(this);
	frame(data.experiment_idx(this) ~= data.experiment_idx(these_pts(i))) = categorical(NaN);
	state_matrix(:,i) = frame;

	PD_f(:,i) = sum(~isnan(data.PD(this,:)),2)/20;
	LP_f(:,i) = sum(~isnan(data.LP(this,:)),2)/20;
	experiment_idx(i) = data.experiment_idx(these_pts(i));
end



state_prob = zeros(N_before,length(cats));
for i = 1:N_before
	state_prob(i,:) = histcounts(state_matrix(i,:),cats);
	state_prob(i,:) = state_prob(i,:)./sum(state_prob(i,:));
end



% smooth them a little bit
state_prob(isnan(state_prob)) = 0;
for i = 1:length(cats)
	state_prob(:,i) = filtfilt(ones(3,1),3,state_prob(:,i));
end


colors = display.colorscheme(data.idx);


x = 1:N_before;
x = x- x(end);
x = x*20;
h = area(x,state_prob);
for i = 1:length(h)
	h(i).LineStyle = 'none';
	h(i).FaceColor = colors(cats{i});
end

xlabel(['Time before switch to ' state ' (s)'])