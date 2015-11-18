function [splits, nclasses] = mj_genCrossValSets(labels, nfolds, safeFolds, splitOnLabels)
% [splits, nclasses] = mj_genCrossValSets(labels, nfolds, safeFolds, splitOnLabels)
% Creates evenly distributed folds for cross-validation
%
% Input:
%  - labels: column vector
%  - nfolds: number of folds
%  - safeFolds: boolean to deal with situations where the number of samples per
%  class is less than the number of requested folds.
%  - splitOnLabels: different classes goes to different sets. Def. false
%
% Output:
%  - splits: cell-array [nclasses, nfolds]
%
% See also mj_getSplitByIdx
%
% (c) MJMJ/2015
%
% MOD, mjmarin, Feb/2015: new opt 'splitOnLabels'

if ~exist('safeFolds', 'var')
   safeFolds = 1;
end

if ~exist('splitOnLabels', 'var')
   splitOnLabels = false;
end

if size(labels,1) < size(labels,2) % Needed
   labels = labels';
end

ulabs = unique(labels);
nclasses = length(ulabs);

if ~splitOnLabels
   splits = cell(nclasses, nfolds);
   for cix = 1:nclasses, % Split classes evenly
      lab = ulabs(cix);
      idx = find(labels == lab);
      nc = length(idx);
      foldsize = floor(nc / nfolds);
      if foldsize < 1
         if safeFolds
            nfolds = nc;
            foldsize = 1;
         else
            error('Too many folds for so few samples!');
         end
      end
      % Distribute
      for fix = 1:nfolds
         ids = idx(1+(fix-1)*foldsize:fix*foldsize);
         splits{cix,fix} = ids';
      end % fix
   end % cix
else
   splits = cell(1, nfolds);
   rclasses = randperm(nclasses);
   for fix = 1:nfolds
      ncpf = floor(nclasses/nfolds);
      cclasses = rclasses(1+(fix-1)*ncpf:fix*ncpf);
      theSet = [];
      for cix = 1:length(cclasses), % Split
         lab = ulabs(cclasses(cix));
         idx = find(labels == lab);
         theSet = [theSet, idx'];
      end % cix
      % Store
      splits{1,fix} = theSet;
   end % fix
end