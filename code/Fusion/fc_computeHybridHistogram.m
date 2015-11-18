function histograms = fc_computeHybridHistogram(histogramsA, histogramsB, dictionary, K)
    histograms = zeros(size(histogramsA, 1), K);
    
    for i=1:size(histograms, 1)
        % Compute each new FV.
        for j=1:K
            posA = dictionary == j;
            posA = posA(1:size(histogramsA, 2));
            posB = dictionary == j;
            posB = posB(size(histogramsA, 2) + 1:end);
            ha = max(histogramsA(i, posA));
            hb = sum(histogramsB(i, posB)) / sum(dictionary == j);
            if isempty(ha)
                ha = 0;
            end
             if isempty(hb)
                hb = 0;
            end
            histograms(i, j) = (ha + hb) / 2;
        end
    end
end