function newFeats = fc_generateNewSamples(feats, percent, newSamplesRand, newSamplesBand)

if newSamplesRand > 0
    newFeats = cell(newSamplesRand, 1);
    newFeats{1} = feats;
    for i=2:newSamplesRand
        n = size(feats, 2);
        p = randperm(n, round(percent * n));
        newFeats{i} = feats(:, p);
    end
end

if newSamplesBand > 0
    newFeats = cell(newSamplesRand, 1);
    % Join partitions
    features = [];
    for i=1:length(feats)
        features = cat(2, features, feats{i});
    end
    newFeats{1} = features;
    for i=2:newSamplesBand
        newFeats{i} = fc_applyBand(features);
    end
end