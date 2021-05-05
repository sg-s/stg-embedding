% function that looks at a input logical vector  x
% and returns false when it dips to 0 from 1
% meant to be used to exclude subsequent modulator
% pulses after first application
function TF = trueAfterFirstPulse(x)

arguments
	x (:,1) logical
end

TF = logical(x*0);

a = find(diff(x) == -1,1,'first');

if isempty(a)
	return
end


TF(a+1:end) = true; 
