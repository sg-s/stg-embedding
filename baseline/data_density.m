% estimates the density of data amongst possible configurations/states
% using binarized ISI histograms

all_N = [2:20 25:5:50];

f = NaN*all_N;
f_PD = f;
f_LP = f;

parfor i = 1:length(all_N)

	N = all_N(i);

	disp(i)

	[~,VectorizedData] = alldata.binarizedHistograms('NBins',N);


	f(i) = size(unique(VectorizedData,'rows'),1);
	f_LP(i) = size(unique(VectorizedData(N+1:2*N,:),'rows'),1);
	f_PD(i) = size(unique(VectorizedData(1:N,:),'rows'),1);
end


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

show_this = 207;
ax = subplot(2,4,1); hold on
data(show_this).snakePlot(ax);
ax.XLim = [1e-2 1];
xlabel(ax,'PD ISI (s)')

show_N_bins = [5 10 30];
for i = 1:length(show_N_bins)
	subplot(2,4,1+i); hold on
	p = data(show_this).binarizedHistograms('NBins',show_N_bins(i));
	imagesc(p.PD_PD>0);
	colormap([1 1 1; color.onehalf('blue')])
	set(gca,'YDir','reverse')
	axis off
end


subplot(2,2,3); hold on
plot(all_N,f,'k')
plot(all_N,2.^((all_N*4)),'r')
xlabel('# of ISI bins')
ylabel('# of unique ISI patterns')
set(gca,'XScale','linear','YScale','log')
set(gca,'YLim',[1 1e5])

subplot(2,2,4); hold on
plot(all_N,f./(2.^((all_N*4))),'k')
set(gca,'XScale','linear','YScale','log')
xlabel('# of ISI bins')
ylabel('Data density')

figlib.pretty
