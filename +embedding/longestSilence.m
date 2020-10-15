
% TO DO: make this a method of DataStore

function longest_silence = longestSilence(alldata)

arguments 
	alldata (1,1) embedding.DataStore
end

% longest silence
disp('Computing longest silence...')
N = size(alldata.mask,1);

longest_silence = ones(N,1)*20;

for i = 1:N
	spikes = [alldata.PD(i,:) alldata.LP(i,:)];
	spikes = spikes - nanmin(spikes);
	spikes(end) = 20;
	spikes = sort(spikes);
	longest_silence(i) = nanmax(diff(spikes));
end

longest_silence(isnan(longest_silence)) = 20;