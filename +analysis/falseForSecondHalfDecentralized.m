% returns False for second half of decentralized
% only without any modulator, true all other times

function TF = falseForSecondHalfDecentralized(data)

arguments
	data (1,1) embedding.DataStore
end

TF = logical(data.mask*0 + 1);

a = find(data.decentralized,1,'first');
z = find(data.modulator,1,'first');

assert(~isempty(a),'Could not identify decentralized start')
assert(~isempty(z),'Could not identify modulator start')

assert(z>a,[char(data.experiment_idx(1)) '--Prep was not decentralized before mod added'])


TF(a+floor((z-a)/2):z-1) = false;