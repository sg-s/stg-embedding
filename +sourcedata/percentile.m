% computes percentiles for all data
% 
function p = percentile(alldata)


N = length(alldata.mask);

% compute cumulative histograms for all ISIs
types = {'PD_PD','LP_LP','LP_PD','PD_LP'};


percentiles = linspace(0,100,51);

for i = 1:length(types)
    p.(types{i}) = NaN(N,length(percentiles));

    for j = 1:N
        temp = alldata.(types{i})(j,:);
        p.(types{i})(j,:) = prctile(temp,percentiles);
    end

end