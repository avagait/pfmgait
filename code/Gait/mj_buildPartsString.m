function [extrafixdir, extrafixexper] = mj_buildPartsString(partitions)
% experfix = mj_buildPartsString(partitions)
% COMMENT ME!!!
%
% Input:
%  - partitions: struct-array with fields used in the experiments
%
% (c) MJMJ/2013

extrafixdir = '';
extrafixexper = '';

% Find partition length
if length(partitions(1).partition) == 1
   extrafixdir = [extrafixdir sprintf('_part%02d', partitions(1).partition)];
end

% Find join
if isfield(partitions, 'join')   
   jn = [partitions.join];
   if all(jn > 0) %
      extrafixexper = [extrafixexper '_jn'];
%    elseif any(jn > 0)
%       %extrafixexper = [extrafixexper '_pyr'];
%       pyrfix = '_pyr';
   end
end

pyrfix = '';
if mj_isGaitPyramid(partitions)
   pyrfix = '_pyr';
end

extrafixdir = [extrafixdir pyrfix];


