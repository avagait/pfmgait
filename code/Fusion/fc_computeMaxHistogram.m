function histograms = fc_computeMaxHistogram(histogramsA, histogramsB, dictionary, K)
    histograms = zeros(size(histogramsA, 1), K);
    
    for i=1:size(histograms, 1)
        % Compute each new FV.
        for j=1:K
            posA = dictionary == j;
            posA = posA(1:size(histogramsA, 2));
            posB = dictionary == j;
            posB = posB(size(histogramsA, 2) + 1:end);
            ha = sum(histogramsA(i, posA));
            hb = sum(histogramsB(i, posB));
            if isempty(ha)
                ha = 0;
            end
             if isempty(hb)
                hb = 0;
            end
            histograms(i, j) = max(ha, hb);
        end
    end
end
