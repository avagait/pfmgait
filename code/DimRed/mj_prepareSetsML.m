function sData = mj_prepareSetsML(samples, labels, posIt)
% sData = mj_prepareSetsML(samples, labels, posIt)
% Prepare sets for Metric Learning
% COMMENT ME!!!   
%
% Input:
%  - samples: matrix [nsamples, ndims]
%  - labels: column vector
%  - posIt: number of iterations for generating positive pairs
%
% Output:
%  - sData: struct with fields
%     .feats
%     .posPairs
%     .negPairs
%     .dimredModelInit
% 
% See also mj_preparePairsML
%
% (c) MJMJ/2014

if ~exist('posIt', 'var')
   posIt = 1;
end

%% Do it!
[sData.posPairs, sData.negPairs] = mj_preparePairsML(labels, posIt);

sData.feats = samples';
clear samples

sData.dimredModelInit = [];