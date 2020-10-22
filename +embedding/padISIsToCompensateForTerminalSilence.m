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


validation.firstDimensionEqualSize(PD,LP,PD_PD,LP_LP);

offsets = min([PD LP],[],2);

for i = 1:size(PD,1)

	maxISI = max(PD_PD(i,:));

	% first, check that there is no big blank period in the beginning of the snippet
	if min(PD(i,:) - offsets(i)) > 2*maxISI
		PD_PD(i,find(isnan(PD_PD(i,:)),1,'first')) = min(PD(i,:) - offsets(i));
	end

	% now check for big blank periods at the end of the snippet
	if max(PD(i,:) - offsets(i)) + 2*maxISI < 20
		PD_PD(i,find(isnan(PD_PD(i,:)),1,'first')) = 20 - max(PD(i,:) - offsets(i));
	end 



	% first, check that there is no big blank period in the beginning of the snippet
	if min(LP(i,:) - offsets(i)) > 2*maxISI
		LP_LP(i,find(isnan(LP_LP(i,:)),1,'first')) = min(LP(i,:) - offsets(i));
	end

	% now check for big blank periods at the end of the snippet
	if max(LP(i,:) - offsets(i)) + 2*maxISI < 20
		LP_LP(i,find(isnan(LP_LP(i,:)),1,'first')) = 20 - max(LP(i,:) - offsets(i));
	end 

end