

% here we compare variability in metrics before decentralization,
% and 500s after decentralization 


init
close all


% drawing constants
lp_color = color.aqua('red');
pd_color = color.aqua('indigo');





% average things by prep

CV_before = struct; % stores the CVs of each metric
CV_after = struct; % stores the CVs of each metric
fn = fieldnames(decmetrics);
fn = setdiff(fn,{'PD_nspikes','LP_nspikes','PD_delay_on','PD_phase_on','LP_burst_period'});

time_since_decentralization = analysis.timeSinceDecentralization(decdata);


for i = 1:length(fn)
	disp(fn{i})

	

	% firrst before decentralization
	this = decmetrics.(fn{i});
	this(decdata.decentralized == true) = NaN;
	groups = decdata.experiment_idx;
	rm_this = decdata.idx ~= 'normal';
	this(rm_this) = [];
	groups(rm_this) = [];
	[M,S] = analysis.averageBy(this,groups);
	CV_before.(fn{i}) = S./M;

	%  after decentralization
	this = decmetrics.(fn{i});
	this(time_since_decentralization < 500) = NaN;
	groups = decdata.experiment_idx;
	rm_this = decdata.idx ~= 'normal';
	this(rm_this) = [];
	groups(rm_this) = [];
	[M,S] = analysis.averageBy(this,groups);
	CV_after.(fn{i}) = S./M;



end


figure('outerposition',[300 300 1200 1111],'PaperUnits','points','PaperSize',[1200 1111]); hold on

for i = 1:length(fn)
	subplot(3,3,i); hold on
	plot(CV_before.(fn{i}),CV_after.(fn{i}),'k.')
	set(gca,'XScale','log','YScale','log','XLim',[1e-3 1],'YLim',[1e-3 1])
	plotlib.drawDiag(gca,'k--');
	p=statlib.pairedPermutationTest(CV_before.(fn{i}),CV_after.(fn{i}))
	title(fn{i},'interpreter','none')
end



