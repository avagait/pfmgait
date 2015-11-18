function finalSample = fc_computeRandomSubspace(sample)
% finalSample = fc_computeRandomSubspace(sample)
% Compute a new sample using a random subspace.
%
% Input:
%  - sample: training sample [nsamples, ndims]
%
% Output:
%  - finalSample: new sample [nsamples, ndims]. Unused dims
%    are equals to 0.
%
    finalSample = zeros(size(sample));
    p = randperm(size(sample, 1));
    lim = round(sqrt(size(sample, 1)));
    finalSample(p(1:lim), :) = sample(p(1:lim), :);
end