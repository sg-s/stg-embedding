function F = firingRates(data)

arguments
	data (1,1) embedding.DataStore
end

F = [sum(~isnan(data.PD),2) sum(~isnan(data.LP),2)]/20;