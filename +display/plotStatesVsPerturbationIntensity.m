function plotStatesVsPerturbationIntensity(data,only_when,pert)

arguments
	data (1,1) embedding.DataStore
	only_when (:,1) logical 
	pert char {mustBeMember(pert,{'temperature','pH'})}

end

unique_preps = unique(data.experiment_idx(only_when));
N = length(unique_preps);
offset = 1;
for i = 1:N
	% get all time, pH and idx
	this = data.experiment_idx == unique_preps(i) & only_when;
	time = data.time_offset(this);
	thing = data.(pert)(this);
	idx = data.idx(this);

	% find points where they go silent
	switch_to_silent = find([0; diff(idx == 'silent') == 1]);

	if isempty(switch_to_silent)
		continue
	end

	labels = veclib.labelSegments([20; (diff(time))] ~= 20);


	% for each transition to silent, go back in time 
	% for the continuous time segment, and pull out data 
	for j = 1:length(switch_to_silent)
		
		% need to make sure that there is no switch after a
		if j == 1
			a = find(labels == labels(switch_to_silent(j)),1,'first');
		else
			a = find(labels == labels(switch_to_silent(j)));
			a = a(a>switch_to_silent(j-1));
			a = a(1);
		end
		these_idx = idx(a:switch_to_silent(j));
		these_things = thing(a:switch_to_silent(j));
		these_things = these_things - these_things(end);


		display.plotStates(gca,these_idx,these_things,offset,'LineWidth',10,'MarkerSize',30);
	

	end
	offset = offset+1;
end