% if in a segment, a neuron 
% stops firing, then that is not captured
% by simple ISIs. So we need to pad the ISI
% by pretending there is a fake spike at the end
% of that window

function [PD_PD, LP_LP] = padISIsToCompensateForTerminalSilence(PD, LP, PD_PD, LP_LP)

arguments 
	PD (:,1e3) double 
	LP (:,1e3) double
	PD_PD (:,1e3) double 
	LP_LP (:,1e3) double
end


offsets = min([PD LP],[],2);

for i = 1:size(PD,1)

	if max(PD(i,:) - offsets(i)) + 2*max(PD_PD(i,:)) < 20
		PD_PD(i,find(isnan(PD_PD(i,:)),1,'first')) = 20 - max(PD(i,:) - offsets(i));
	end 

	if max(LP(i,:) - offsets(i)) + 2*max(LP_LP(i,:)) < 20
		LP_LP(i,find(isnan(LP_LP(i,:)),1,'first')) = 20 - max(LP(i,:) - offsets(i));
	end 

end