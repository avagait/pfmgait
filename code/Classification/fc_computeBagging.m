function [subsample, sublabels] = fc_computeBagging(psix, labels, ci)
% [subsample, sublabels] = fc_computeBagging(psix, labels, ci)
% Compute a new sample using a bagging.
%
% Input:
%  - psix: training sample [nsamples, ndims]
%  - labels: labels of the samples.
%  - ci: index of the current class.
%
% Output:
%  - subsample: new sample [nsamples, ndims]. nsamples is 2*nsamples of the
%  current class.
%  - sublabels: labels of the output samples.
%
    valix = labels > 0;
    ulabs = unique(labels(valix));
    sp = sum(labels == ulabs(ci)); % Split point.
    % Negative samples.
    negative = psix(:, labels ~= ulabs(ci));
    negativeLabels = labels(labels ~= ulabs(ci));
    % Add positive samples.
    subsample = zeros(size(psix, 1), 2*sum(labels == ulabs(ci)));
    subsample(:, 1:sp) = psix(:, labels == ulabs(ci));
    % Add negative samples.
    p = randperm(size(negative, 2));
    subsample(:, sp+1:end) = negative(:, p(1:sp));
    sublabels = labels(labels == ulabs(ci));
    sublabels = [sublabels ; negativeLabels(p(1:sp))];
end