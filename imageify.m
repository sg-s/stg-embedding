% this function converts data that is returned by 
% crabsort.consolidate
% into discretized data, like an image

function binned_data = imageify(data, varargin)


% options and defaults
options.n_bins = 20;
options.min_isi = 3e-3;
options.max_isi = 5;
options.window_size = 10; % seconds
options.neurons = [];

if nargout && ~nargin 
	varargout{1} = options;
    return
end

% validate and accept options
if iseven(length(varargin))
	for ii = 1:2:length(varargin)-1
	temp = varargin{ii};
    if ischar(temp)
    	if ~any(find(strcmp(temp,fieldnames(options))))
    		disp(['Unknown option: ' temp])
    		disp('The allowed options are:')
    		disp(fieldnames(options))
    		error('UNKNOWN OPTION')
    	else
    		options.(temp) = varargin{ii+1};
    	end
    end
end
elseif isstruct(varargin{1})
	% should be OK...
	options = varargin{1};
else
	error('Inputs need to be name value pairs')
end


if isempty(options.neurons)
	error('Neurons not specified')
end


% make a list of metdata variables from the fields of data
metdata_variables = {};
fn = fieldnames(data);
for i = 1:length(fn)
	if any(isstrprop(fn{i},'upper'))
		continue
	end
	metdata_variables = [metdata_variables; fn{i}];
end

bin_edges = logspace(log10(options.min_isi), log10(options.max_isi),options.n_bins+1);
bin_centres = bin_edges(1:end-1)+diff(bin_edges)/2;
N = length(options.neurons);
M = zeros((N^2)*options.n_bins,1e3);
idx = 1;

binned_data = struct;
for i = 1:length(metdata_variables)
	binned_data.(metdata_variables{i}) = NaN(1e3,1);
end

for i = 1:length(data)


	a = 0;
	z = a + options.window_size;


	while z < data(i).T


		A = 1;
		Z = A + options.n_bins-1;

		for j = 1:N
			for k = 1:N

				this_isi = data(i).([options.neurons{j} '_' options.neurons{k}]);

							
				in_frame = data(i).(options.neurons{j}) > a & data(i).(options.neurons{j}) < z;
				if length(in_frame) > length(this_isi) 
					in_frame = in_frame(1:length(this_isi));
				end
				frame = this_isi(in_frame);
				frame(isinf(frame)) = [];
				H = histcounts(frame,bin_edges);

				H =H.*bin_centres;

				if sum(H) > 0 
					H = H/sum(H);
				end

				if any(isnan(H))
					keyboard
				end

				% add into matrix
				M(A:Z,idx) = H;

				A = Z;
				Z = A + options.n_bins-1;


			end

		end

		

		% add metadata
		for j = 1:length(metdata_variables)
			binned_data.(metdata_variables{j})(idx) = data(i).(metdata_variables{j});
		end

		a = z;
		z = a + options.window_size;
		idx =  idx + 1;


	end



end

M = M(:,1:idx-1);

binned_data.M = M;