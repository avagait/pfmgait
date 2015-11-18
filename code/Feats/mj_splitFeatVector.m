function lfeats = mj_splitFeatVector(vfeats, vdims, sqrtsel)
% lfeats = mj_splitFeatVector(vfeats, vdims, sqrtsel)
% Split concatenated feature vectors into their components
%
% Input:
%  - vfeats: matrix [nsamples, ndims]. 
%  - vdims: vector with dimensions per type of feature, where sum(vdims) <= ndims, E.g. [30 96 96 96]
%  - sqrtsel: boolean vector. E.g. [0 1 1 1] for DCS features
% 
% Ouput: 
%  - lfeats: cell-array
%
% (c) MJMJ/2014
%
% MOD, mjmarin, 12/Dic/2014: opt to compute sqrt of selected features

if ~exist('sqrtsel', 'var')
   sqrtsel = [];
end
doSqrt = ~isempty(sqrtsel) && any(sqrtsel);


nsplits = length(vdims);
lfeats = cell(nsplits, 1);

inipos = 1;
for i = 1:nsplits,
   samples = vfeats(:, inipos:inipos+vdims(i)-1);
   
   if doSqrt && sqrtsel(i)
      samples = sqrt(samples);
   end
   lfeats{i} = samples;
   clear samples
   
   inipos = inipos+vdims(i);
end % i
