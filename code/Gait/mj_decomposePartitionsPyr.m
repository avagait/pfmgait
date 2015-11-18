function l_partitions = mj_decomposePartitionsPyr(partitions)
% l_partitions = mj_decomposePartitionsPyr(partitions)
% COMMENT ME!!!
%
% Output:
%  - l_partitions: cell-array of struct-array
%
% (c) MJMJ/2013

l_partitions = [];

if ~mj_isGaitPyramid(partitions) % Nothing to do
   return
end

jn = [partitions.join];

for jix = 0:1,
   l_partitions{jix+1} = [partitions(jn == jix)];
end % jix
