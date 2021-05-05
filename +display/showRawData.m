% helper function to show raw data

function showRawData(options)

arguments
	options.ax (1,1) = gca
	options.t_start (1,1) double = 0
	options.filename
	options.experiment_idx
	options.nerves (2,1) cell = {'lvn','pdn'};
end


hash = structlib.md5hash(rmfield(options,'ax'));
cachename = fullfile('../cache',[hash '.mat']);

if exist(cachename,'file') == 2
	load(cachename,'X')
else
	temp = crabsort.open(options.experiment_idx,true);
	C = crabsort(false);
	C.path_name = temp.folder;


	C.file_name = options.filename;
	C.loadFile;

	for i = 2:-1:1
		temp = strcmp(C.common.data_channel_names,options.nerves{i});
		X(:,i) = C.raw_data(C.time > options.t_start & (C.time < options.t_start + 20),temp);
		X(:,i) = X(:,i) - nanmean(X(:,i));
		X(:,i) = X(:,i)/abs(max(X(:,i)));
		X(:,i) = X(:,i) + (i-1)*2.2;
	end

	save(cachename,'X');
end

neurons = {'LP','PD'};
colors = display.colorscheme(NaN);

for i = 1:length(options.nerves)
	
	time = linspace(0,20,length(X));
	plot(options.ax,time,X(:,i),'Color',colors.(neurons{i}));
	th = text(options.ax,-1,(i-1)*2.2,['\it' options.nerves{i}],'FontSize',20,'Color',colors.(neurons{i}),'HorizontalAlignment','right');
	if strcmp(options.nerves{i},upper(options.nerves{i}))
		th.String = options.nerves{i};
	end

end

options.ax.YLim = [-1.5 3.5];
axis(options.ax,'off')



