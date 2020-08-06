% this function reads in hand-annotations of metadata for the rosenbaum
% data because the experimenter-recorded annotations are useless
% 
function data = rosenbaum(data)

% mark the modulator on
load('../annotations/rosenbaum_modulator_on.mat','mmm')

for i = 1:length(data)

	this_exp = data(i).experiment_idx(1);
	use_this = find([mmm.experiment_idx] == this_exp,1,'last');

	if isempty(use_this)
		continue
	end

	if ~any(data(i).decentralized)
		% never decentralized, do don't use this
		continue
	end


	filestart = find(data(i).filename == mmm(use_this).filename,1,'first');
	time_offset = data(i).time_offset;
	time_offset = time_offset - time_offset(filestart);

	mod_on = find(time_offset == mmm(use_this).time & data(i).filename == mmm(use_this).filename);

	if isempty(mod_on)
		keyboard
	end

	mod_name = char(sourcedata.modulatorUsed(data(i)));
	max_mod = max(data(i).(mod_name));

	data(i).(mod_name)(:) = 0;
	data(i).(mod_name)(mod_on:end) = max_mod;

end

clearvars mmm

% now mark decentralized 
load('../annotations/rosenbaum_decentralized.mat','mmm')

for i = 1:length(data)

	this_exp = data(i).experiment_idx(1);
	use_this = find([mmm.experiment_idx] == this_exp,1,'last');

	if isempty(use_this)
		continue
	end

	if ~any(data(i).decentralized)
		% never decentralized, do don't use this
		continue
	end


	filestart = find(data(i).filename == mmm(use_this).filename,1,'first');
	time_offset = data(i).time_offset;
	time_offset = time_offset - time_offset(filestart);

	decentralized = find(time_offset == mmm(use_this).time & data(i).filename == mmm(use_this).filename);

	if isempty(decentralized)
		keyboard
	end


	data(i).decentralized(:) = false;
	data(i).decentralized(decentralized:end) = true;


end