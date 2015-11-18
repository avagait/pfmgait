function h = mj_encodeMultiDict(data, dictionaries, pars)
% h = mj_encodeMultiDict(data, dictionaries, pars)
% Encodes data with input set of dictionaries
% Input:
%  - data: matrix [ndims, nlocfeats] local features
%  - dictionaries: cell-array of dictionaries of class FV
%  - pars: struct with fields:
%     .ftdims: vector of lengths
%     .ftsel: vector of boolean
%     .sqrt: vector of boolean
%
% Output:
%  - h: encoded feature vector
%
% See also mj_splitFeatVector
%
% (c) MJMJ/2014
%
% MOD, mjmarin, Dic/2014: new option to compute sqrt of features before encoding

h = [];

if isempty(data)
   return
end

if ~isfield(pars, 'sqrt')
   pars.sqrt = [];
end
%doSqrt = ~isempty(pars.sqrt) && any(pars.sqrt);

lms = mj_splitFeatVector(data', pars.ftdims, pars.sqrt); % DEVELOP!!! %lms = mj_splitFeatVector(data', [30 96 96 96]); % DEVELOP!!!

for dix_ = 1:length(dictionaries)
   if ~isscalar(pars.ftsel) && ~pars.ftsel(dix_)
      continue
   end
   dictionary_ = dictionaries{dix_};
   
   samples = lms{dix_};
   
   h_d = dictionary_.encode(samples');
   clear samples
   
   h = [h; h_d];
end % dix_
