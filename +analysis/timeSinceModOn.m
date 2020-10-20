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

a = find(modulator,1,'first');

time = data.time_offset;
time = time - time(a);

z = find(modulator(a:end)==0,1,'first');

time(a+z-1:end) = NaN;

keyboard