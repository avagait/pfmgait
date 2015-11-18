function b = mj_isGaitPyramid(partitions)
% b = mj_isGaitPyramid(partitions)
% Checks whether is a pyramidal configuration.
%
% Input:
%  - partitions: struct-array
%
% Output:
%  - b: 'true' if is a pyramidal configuration.
%
% (c) MJMJ/2013

b = false;

if isfield(partitions, 'join')   
   jn = [partitions.join];
   if ~all(jn > 0) && any(jn > 0)
      b = true;
   end
end