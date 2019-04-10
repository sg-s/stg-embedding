% converts a vector of chunked data
% returned by chunk into a giant ISI amtrix
% also creates metadata matrices
% and packgaes everything together into
% a structure called M
%
% typical workflow:
% data <-- from crabsort.merge, crabsort.consolidate
% cdata <-- from chunk
% use cdata as an input to this function

function M = matrixify(cdata, varargin)


% options and defaults


options.window_size = 10; % seconds
options.neurons = [];

options = corelib.parseNameValueArguments(options,varargin{:});


if isempty(options.neurons)
	error('Neurons not specified')
end


% make a list of metdata variables from the fields of data
metdata_variables = {};
fn = fieldnames(cdata);
for i = length(fn):-1:1
	if any(isstrprop(fn{i},'upper'))
		continue
	end
	metdata_variables = [metdata_variables; fn{i}];
end




M = struct;
for i = 1:length(metdata_variables)
	M.(metdata_variables{i}) = vertcat(cdata.(metdata_variables{i}));
end


% need to compute the size of the ISI matrix
% for each set of ISIs
ISI_combinations = {};
for i = 1:length(options.neurons)
	for j = 1:length(options.neurons)
		ISI_combinations{end+1} = [options.neurons{i} '_' options.neurons{j}];
	end
end

n_isis = zeros(length(cdata),length(ISI_combinations));

for i = 1:length(cdata)
	for j = 1:length(ISI_combinations)
		n_isis(i,j) = length(cdata(i).(ISI_combinations{j}));
	end
end

N = max(max(n_isis));

for i = 1:length(ISI_combinations)
	M.(ISI_combinations{i}) = NaN(length(cdata),N);
end

for i = 1:length(cdata)
	for j = 1:length(ISI_combinations)
		this_isis = cdata(i).(ISI_combinations{j});
		M.(ISI_combinations{j})(i,1:length(this_isis)) = this_isis;
	end

end


% also combine all the spike times
N = N + 1;

for i = 1:length(options.neurons)
	M.(options.neurons{i}) = NaN(length(cdata),N);
end


for i = 1:length(cdata)
	for j = 1:length(options.neurons)
		spiketimes = cdata(i).(options.neurons{j});
		M.(options.neurons{j})(i,1:length(spiketimes)) = spiketimes;
	end

end