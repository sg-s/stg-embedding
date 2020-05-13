% filters data for certain conditions

function only_these = filterData(alldata, FilterSpec)

switch FilterSpec

case 'baseline'
	only_these = alldata.decentralized == 0;
case 'decentralized'
	only_these = alldata.time_since_mod_on < 0 & alldata.time_since_mod_on > -600;
otherwise
	only_these = alldata.(FilterSpec) > 0;
end