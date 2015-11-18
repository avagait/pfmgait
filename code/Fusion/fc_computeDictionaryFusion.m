function dictionary = fc_computeDictionaryFusion(histogramsA, histogramsB, K)
    % Normalize data.
    histogramsA = histogramsA + 1;
    histogramsB = histogramsB + 1;

    % Obtain correlation matrix S.
    N = sum(histogramsA)' * sum(histogramsB);
    S = histogramsA' * histogramsB;
    S = S./N;

    D1 = diag(1 ./ sqrt(sum(S, 2)));
    D2 = diag(1 ./ sqrt(sum(S, 1)));
    
    % Obtaining S normalized.
    Snorm = D1 * S * D2;
    
    % Computing SVD on S normalized.
    l = ceil(log2(K));
    [U, ~, V] = svds(double(Snorm), l);
    U = U(:, 2:end);
    V = V(:, 2:end);
    
    % Obtain Z.
    Z1 = D1 * U;
    Z2 = D2 * V;
    Z = [Z1 ; Z2];
    
    % Obtain new dictionary.
    [idx, ~] = kmeans(Z, K);
    dictionary = idx;
end
