function matrix = fc_calculateFeatsMatrix(features, partition)
% function matrix = fc_calculateFeatsMatrix(features, partition)
% Build a matrix with the arrays of features of the motion flows of one person. 
%
% Input:
%  - features: Features of one person.
%  - partition: selected partition of the full body detection. Can be a vector
%
% Output:
%  - matrix: Matrix with the arrays of features.
%
% MOD: mjmarin, 10/Dic/2013: partition can be a vector of part ids. E.g. [1 2]
%                            +memory pre-allocation for better performance
%                            +parfor when multiple partitions

% Building the matrix.
matrix = [];

if isempty(features) || isempty(features{partition(end)})
   disp('WARN: features is empty!!!');
   return
end

if length(partition) == 1
   if partition < 0
      for i=1:length(features)
         for j=1:length(features{i})
            matrix = [matrix, features{i}(j).feats];
         end
      end
   else
      matrix = zeros(length( features{partition}(1).feats), length(features{partition}),'single'); % Pre-allocate memory
      for i=1:length(features{partition})
         matrix(:,i) = features{partition}(i).feats; %[matrix, features{partition}(i).feats];
      end
   end
else   
   np = length(partition);
   matrix = cell(1,np);
   parfor k = 1:np
      matrix_ = zeros(length( features{partition(k)}(1).feats), length(features{partition(k)}),'single'); % Pre-allocate memory
      for i=1:length(features{partition(k)})
         matrix_(:,i) = features{partition(k)}(i).feats; %matrix_ = [matrix_, features{partition(k)}(i).feats];
      end
      matrix{k} = matrix_;
   end % np
end % if
