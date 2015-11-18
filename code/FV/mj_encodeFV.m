function h = mj_encodeFV(samples, dictionary, pars)
% h = mj_encodeFV(samples, dictionary, pars)
% High-level method to encode features with a Fisher Vector
% Input:
%  - dictionary
%  - samples: [ndims, nsamples]
%  - pars: extra parameters
%
% Output:
%  - h: encoded features
%
% (c) MJMJ/2014

if ~exist('pars', 'var')
   pars = [];
end

if ~isfield(pars, 'sqrt')
   pars.sqrt = [];   
end

%% Do it!
if iscell(dictionary) % Multi-dictionary
   h = mj_encodeMultiDict(samples, dictionary, pars);
else
   doSqrt = ~isempty(pars.sqrt) && any(pars.sqrt);   
   if doSqrt
      lms = mj_splitFeatVector(samples', pars.ftdims, pars.sqrt);            
      samples = mj_joinFeatVectors(lms);
      samples = samples';
   end
   h = dictionary.encode(samples); % mjmarin: make sure matrix is [ndims, nsamples]
end