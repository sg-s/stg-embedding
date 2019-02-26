function cdata = chunk(data, varargin)

% options and defaults


options.window_size = 10; % seconds
options.neurons = [];


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
for i = length(fn):-1:1
	if any(isstrprop(fn{i},'upper'))
		continue
	end
	metdata_variables = [metdata_variables; fn{i}];
end

N = length(options.neurons);
idx = 1;

cdata = struct;
for i = 1:length(metdata_variables)
	cdata.(metdata_variables{i}) = NaN(1e3,1);
end

for i = 1:length(data)


	a = 0;
	z = a + options.window_size;


	while z < data(i).T



		for j = 1:N
			for k = 1:N

				

				this_isi = data(i).([options.neurons{j} '_' options.neurons{k}]);

							
				in_frame = data(i).(options.neurons{j}) > a & data(i).(options.neurons{j}) < z;
				if length(in_frame) > length(this_isi) 
					in_frame = in_frame(1:length(this_isi));
				end
				frame = this_isi(in_frame);
				frame(isinf(frame)) = [];


				% add
				cdata(idx).([options.neurons{j} '_' options.neurons{k}]) = frame;


			end

		end

		

		% add metadata
		for j = 1:length(metdata_variables)
			cdata(idx).(metdata_variables{j}) = data(i).(metdata_variables{j});
		end

		a = z;
		z = a + options.window_size;
		idx =  idx + 1;


	end



end

