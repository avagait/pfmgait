function [data, M, P] = mj_zcaWhite(data, cte, M, P)
% [data, M, P] = mj_zcaWhite(data, cte, M, P)
% ZCA data whitening
%
% Input:
%  - data: [nsamples, ndims]
%  - cte: constant. [Optional] E.g. 0.001
%  - M: mean. [Optional]
%  - P: whitening matrix [Optional]
%
% Based on code from: http://www.cs.toronto.edu/~kriz
% See Coates's thesis for details
%
% (c) MJMJ/2013

data = single(data); % Keep memory safe

if nargin <= 2 % Much faster!   
   if ~exist('cte', 'var')
      cte = 0.001;
   end
   
   if ~exist('M', 'var')
      M = mean(data);
   end
   
   if ~exist('P', 'var')
      C = cov(data);
      [V,D] = eig(C);
      P = V * diag(sqrt(1./(diag(D) + cte))) * V'; % To avoid divide-by-zero
   end
end

data = bsxfun(@minus, data, M) * P;

