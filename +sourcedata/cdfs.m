function cdfs = cdfs(alldata)

N = length(alldata.mask);

% compute cumulative histograms for all ISIs
types = {'PD_PD','LP_LP','LP_PD','PD_LP'};
nbins = 100;
bins = logspace(-2,1,nbins+1);
for i = 1:length(types)
    cdfs.(types{i}) = NaN(N,nbins);

    for j = 1:N
        temp = alldata.(types{i})(j,:);
        temp(isnan(temp)) = [];
        if isempty(temp)
            continue
        end

        cdfs.(types{i})(j,:) = histcounts(temp,bins,'Normalization','cdf');
    end

end