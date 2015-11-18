function [pairs, pDist] = mj_rankSimilarPairs(samples, labels, newDim, sorted)
% [pairs, pDist] = mj_rankSimilarPairs(samples, labels, newDim, sorted)
% Computes euclidean distance between pairs of samples of different classes
% after performing PCA dimensionality reduction. Returned pairs are known as
% 'hard negatives'.
%
% Input:
%  - samples: matrix [nsamples, ndims]
%  - labels: column vector
%  - newDim: for PCA e.g. 256
%  - sorted: sort output based on distance? Lowest is the first pair
%
% Output:
%  - pairs: matrix [2, npairs] with pairs indeces.
%  - pDist: Euclidean distance of each pair, lower distances mean harder negatives.
%
% See also mj_PCA, vl_alldist2
%
% (c) MJMJ/2015

if ~exist('sorted', 'var')
   sorted = false;
end

%% Output
pairs = [];
pDist = [];

%% PCA dim reduction
pcaobj = mj_PCA(samples, newDim);
samples = pcaobj.encode(samples);
clear pcaobj

%% Compare different subjects
ulabs = unique(labels);
nlabs = length(ulabs);
PORC = 0.5; % DEVELOP!!!

for i = 1:nlabs-1,
   ix = find(labels == ulabs(i));
   isamp = samples(ix,:);
   for j = i+1:nlabs,
      jx = find(labels == ulabs(j));
      jsamp = samples(jx, :);
      
      % All pairs comparison
      D = vl_alldist2(isamp', jsamp');
      
      % Sort distances
      for ii = 1:size(D,1)
         [d, oix] = sort(D(ii,:));
         for jj = 1:max(1, floor(length(oix)*PORC) )
            pairs = [pairs, [ix(ii); jx(oix(jj))] ];
            pDist = [pDist; d(jj)]; 
         end
      end % ii
   end % 
end % i

%% Prepare final output
if sorted
   [oDist, oix] = sort(pDist);
   pDist = oDist;
   pairs = pairs(:, oix);
end
