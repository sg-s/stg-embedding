% plots all temperature ramps for inspection

data_root = '/Volumes/DATA/tang/hard-to-sort/';


alldata = dir(data_root);

allramps = [];

names = {};

for i = 1:length(alldata)


	if strcmp(alldata(i).name(1),'.')
		continue
	end

	allfiles = dir([alldata(i).folder filesep alldata(i).name filesep '*.crab']);


	names{i} = strrep(alldata(i).name,'_','-');

	savename = [alldata(i).folder filesep alldata(i).name filesep 'temperature.mat'];


	if exist(savename,'file') == 2
		disp('temp file already exists')

		load(savename,'all_file_idx','all_temp','all_time')
		allramps(i).all_time = all_time;
		allramps(i).all_temp = all_temp;
		allramps(i).all_file_idx = all_file_idx;

		continue
	end

	disp('Measuring temperatures...')

	all_temp = [];
	all_time = [];
	all_file_idx = [];
	offset = 0;
	for j = 1:length(allfiles)


		corelib.textbar(j,length(allfiles))

		clear raw_data dt builtin_channel_names
		load([allfiles(j).folder filesep allfiles(j).name],'builtin_channel_names','raw_data','dt','-mat')
		
		file_idx = str2double(allfiles(j).name(9:12));
		temp_channel = [];


		channel_names = builtin_channel_names;

		for k = 1:length(channel_names)
			if isempty(strfind(lower(channel_names{k}),'temp'))
				continue
			end
			temp_channel = k;
			break
		end




		if isempty(temp_channel)
			disp('Could not determine temp cahnnel here:')
			disp(alldata(i).name)
			error()
		end

		this_temp = raw_data(1:round(1/dt):end,temp_channel);
		all_temp = [all_temp; this_temp(:)];
		all_time = [all_time; offset + (1:length(this_temp))'];

		all_file_idx = [all_file_idx; this_temp*0 + file_idx];

		offset = all_time(end);



	end

	save(savename,'all_file_idx','all_temp','all_time')


end


% plot all the ramps, aligned by peak
figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on



all_temp = NaN(100e3,length(allramps));

for i = 1:length(allramps)

	if isempty(allramps(i).all_time)
		continue
	end



	time = allramps(i).all_time;
	temp = allramps(i).all_temp;

	temp(temp == 0 )= NaN;


	all_temp(1:length(temp),i) = temp;

end
box off
imagesc(all_temp','AlphaData',~isnan(all_temp'))
set(gca,'XLim',[0 40e3])
set(gca,'YTick',1:length(allramps),'YTickLabel',names)

xlabel('Time (s)')
ylabel('Experiment #')
ch = colorbar;
title(ch,'Temperature (C)')
figlib.pretty()