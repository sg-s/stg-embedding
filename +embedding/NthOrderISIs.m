% computes N-th order ISIs from a set of spiketimes
% this does not compensate for terminal stops
% in activity, so you probably want to pass
% this through padISIsToCompensateForTerminalSilence
% after

function ISIs = NthOrderISIs(spikes,N)

arguments 
	spikes (:,1e3) double
	N (1,1) double {mustBePositive, mustBeInteger} = 2 
end

spikes2 = circshift(spikes,N,2);
ISIs = spikes - spikes2;
ISIs(ISIs<.003) = NaN;




