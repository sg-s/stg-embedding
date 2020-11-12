% this function reads in hand-annotations of metadata for the rosenbaum
% data because the experimenter-recorded annotations are useless
% 
function data = rosenbaumModulatorOn(data)

arguments
	data (1,1) struct
end


if ~any(data.decentralized)
	% never decentralized, don't use this
	return
end

% mark the time of modulator turning on
disp('Modifying Rosenbaum modulator metadata...')


% read the text file with annotations
lines = strsplit(fileread('../annotations/rosenbaum-modulator-on.txt'),'\n')';

this_exp = char(data.experiment_idx(1));

% find the line corresponding to this prep
line_idx = find(cellfun(@(x) any(strfind(x,this_exp)), lines));
if isempty(line_idx)
	return
end

% figure out the modulator being used
modulator = intersect(sourcedata.modulators,fieldnames(data));
assert(length(modulator)==1,'Wrong # of modualators')
modulator = modulator{1};

this_line = strsplit(lines{line_idx},' ');
mod_on_time = str2double(this_line{2});

if mod_on_time == 0
	% we have indicated that there is no percievable change
	% on addition of neuromodulator
	% we should therefore ignore this data because it is suspect
	data.mask(:) = false;
	return
end

assert(~isnan(mod_on_time),'Mod on time cannot be read')

mod_on = find(data.(modulator)>0,1,'first');
true_mod_on = find(data.time_offset(mod_on+1:end) >= mod_on_time,1,'first') + mod_on;



data.(modulator)(1:true_mod_on-1)=0;