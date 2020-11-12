% returns a vector indicating when the modulator was added
% this ignores all applications of modulator other than
% the highest concentration
% it also ignores all subsequent applications of modulator
%


function time = timeSinceModOn(data)

arguments
	data (1,1) embedding.DataStore
end

modulator = data.modulator;

mod_on = find(modulator,1,'first');
mod_off = mod_on + find(modulator(mod_on:end),1,'last') - 1;


time = data.time_offset;


% find any break in time before mod_on
% and after mod_on
% only within these limits can time be defined
last_time_break = find(time(1:mod_on)==0,1,'last');
next_time_break = mod_on+find(time(mod_on+1:end)==0,1,'first');



time(1:last_time_break-1) = NaN;
time(next_time_break:end) = NaN;

time = time - time(mod_on);


