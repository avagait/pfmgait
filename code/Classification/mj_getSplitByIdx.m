function [samplesIdx, labelsIdx, samplesRem, labelsRem] = mj_getSplitByIdx(samples, labels, splits, idx)
% [samplesIdx, labelsIdx, samplesRem, labelsRem] = mj_getSplitByIdx(samples, labels, splits, idx)
% Gets data from previously defined splits. Useful for cross-validation
%
% Input
%  - samples: matrix [nsamples, ndims]
%  - labels: column vector
%  - splits: cell-array returned by 'mj_genCrossValSets'
%  - idx: selected set
%
% Output:
%  - samplesIdx, labelsIdx: corresponding to selected 'idx'
%  - samplesRem, labelsRem: data from remaining splits
%
% See also mj_genCrossValSets
%
% (c) MJMJ/2015

if size(labels,1) < size(labels,2) % Needed
   labels = labels';
end

nsamples = size(samples,1);

idsTest = cell2mat( {splits{:,idx}} );
samplesIdx = samples(idsTest,:);
labelsIdx = labels(idsTest);

idsTrain = setdiff([1:nsamples], idsTest);
samplesRem = samples(idsTrain,:);
labelsRem = labels(idsTrain);