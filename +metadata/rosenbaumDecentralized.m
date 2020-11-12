% this function reads in hand-annotations of metadata for the rosenbaum
% data because the experimenter-recorded annotations are useless
% 
function data = rosenbaumDecentralized(data)

arguments
	data (1,1) struct
end


if ~any(data.decentralized)
	% never decentralized, don't use this
	return
end


this_exp = data.experiment_idx(1);

% now mark decentralized 
load('../annotations/rosenbaum_decentralized.mat','mmm')

disp('Updating decentralization times for Rosenbaum data...')


use_this = find([mmm.experiment_idx] == this_exp,1,'last');

if isempty(use_this)
	return
end



filestart = find(data.filename == mmm(use_this).filename,1,'last');
time_offset = data.time_offset;
time_offset = time_offset - time_offset(filestart);

decentralized = find(time_offset == mmm(use_this).time & data.filename == mmm(use_this).filename);

if isempty(decentralized)
	% we have no annotations, so give up
	return
end


data.decentralized(:) = false;
data.decentralized(decentralized:end) = true;


