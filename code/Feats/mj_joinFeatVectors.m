function samples = mj_joinFeatVectors(lSamples)
% samples = mj_joinFeatVectors(lSamples)
% COMMENT ME!!!
% Input:
%  - lSamples: cell-array
% Output:
%  - samples: matrix [nsamples, ndims]
%
% (c) MJMJ/2014

assert(iscell(lSamples));

nfeats = length(lSamples);

nsamples = size(lSamples{1},1);
ndims = 0;
for fix = 1:nfeats
   ndims = ndims + size(lSamples{fix},2);
end

samples = zeros(nsamples, ndims, class(lSamples{1}));

ini = 1;
for fix = 1:nfeats,   
   cdims = size(lSamples{fix},2);
   samples(:, ini:ini+cdims-1) = lSamples{fix};
   ini = ini + cdims;
end % fix
