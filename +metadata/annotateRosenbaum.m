% In the Rosenbaum data, annotations of when preps
% were decentralized or when neuromodulators were 
% added are almost entirely useless, because the files are massive
% This means that I have no idea WHEN in the file the perturbation
% actually occurred. So the best way around this problem is to 
% eyeball the data and manually mark when we think the prep was decentralized
% or when we think neuromodulator was added 


function annotateRosenbaum(data)

all_exps = unique(vertcat(data.experiment_idx));



for i = 1:length(all_exps)

	close all

	if data(i).experimenter(1) ~= 'rosenbaum'
		continue
	end


	% check if we have annotations for this already
	decentralized_ok = false;
	modulator_ok = false;
	load('../annotations/rosenbaum_decentralized.mat','mmm')
	if any([mmm.experiment_idx] == data(i).experiment_idx(1)) 
		decentralized_ok = true;
	end

	load('../annotations/rosenbaum_modulator_on.mat','mmm')
	if any([mmm.experiment_idx] == data(i).experiment_idx(1))
		modulator_ok = true;
	end

	if decentralized_ok && modulator_ok
		continue
	end

    f = figure('outerposition',[300 300 1200 1000],'PaperUnits','points','PaperSize',[1200 1000]); hold on

    N = '';
    if ~decentralized_ok 
    	N = [N 'No decentralized info....'];
    end
    if ~modulator_ok
    	N = [N 'No modulator info....'];
    end
    f.Name = N;
    f.WindowButtonDownFcn =  @metadata.mouseCallback;
    c = lines;
    filebreaks = [];
    ii=1;
    for j = 2:size(data(i).LP,2)
        if data(i).filename(j) ~= data(i).filename(j-1)
            ii = ii +1;
            filebreaks = [filebreaks j];
        end

        neurolib.raster(data(i).LP(:,j),'split_rows',true,'yoffset',j,'Color',c(ii,:),'LineWidth',5)

    end

    time = (1:size(data(i).LP,2))*20;
    for j = 1:length(filebreaks)
        time(filebreaks(j):end) = time(filebreaks(j):end) - time(filebreaks(j));
    end

    f.UserData.experiment_idx = data(i).experiment_idx(1);
    f.UserData.time = time;
    f.UserData.filename = data(i).filename;

    f.UserData.ph = plotlib.horzline(10,'Color','k','Tag','horzline');

    f.UserData.data_idx = i;

    % add buttons for marking decentralized and modulator 
    uicontrol('Parent',f,'Style','pushbutton','String','Mark decentralized','Units','normalized','Position',[0.1 .01 .2 .1],'Callback',@metadata.markDecentralized);


    txtfiles = dir(fullfile(getpref('crabsort','store_spikes_here'),char(data(i).experiment_idx(1)),'*.txt'));
    edit(fullfile(txtfiles(1).folder,txtfiles(1).name))

    uicontrol('Parent',f,'Style','pushbutton','String','Mark modulator+','Units','normalized','Position',[0.5 .01 .2 .1],'Callback',@metadata.markModulatorOn);


    uiwait(f)

end
