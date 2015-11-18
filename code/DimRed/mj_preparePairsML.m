function [posPairs, negPairs] = mj_preparePairsML(labels, posIt, negIt)
% [posPairs, negPairs] = mj_preparePairsML(labels, posIt, negIt)
% Prepare pairs for Metric Learning
% COMMENT ME!!!   
%
% Input:
%  - labels: column vector
%
% Output:
%  - posPairs, negPairs: matrix [2, npairs]
%
% (c) MJMJ/2014

if ~exist('posIt', 'var')
   posIt = 1;
end

if ~exist('negIt', 'var')
   negIt = 1;
end

if size(labels,1) > size(labels,2)
   labels = labels';
end

posPairs = [];
negPairs = [];

ulabs = unique(labels);
nl = length(ulabs);

%% Positive pairs (same class)
for ix = 1:nl
   lab = ulabs(ix);
   idx = find(labels == lab);
   
   if length(idx) < 2, % Skip if just one sample
      continue
   end
   
   for iter = 1:posIt
      rp = randperm(length(idx));
      rp2 = randperm(length(idx));
      posPairs = [posPairs, [idx(rp); idx(rp2)]];
   end
end % ix
clear idx

%% Negative pairs (different classes)
for ix = 1:nl
   lab = ulabs(ix);
   idxp = find(labels == lab); % This class
   idxn = find(labels ~= lab); % Other classes
      
   for iter = 1:negIt
      rpp = randperm(length(idxp));
      rpn = randperm(length(idxn));
      
      ns = min(length(rpp), length(rpn));
      
      negPairs = [negPairs, [idxp(rpp(1:ns)); idxn(rpn(1:ns))]];
   end % iter
end % ix


