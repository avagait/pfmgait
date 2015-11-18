% (c) MJMJ/2014

% Check if used partitions exists.
if ~exist('partitions_train', 'var')
    partition1.partition = 1;
    partition1.nHorizontalPartitions = 1;
    partition1.nVerticalPartitions = 2;
    partition1.mirror = 0;
    partition1.nFrames = 0;
    partition1.overlap = 0;
    
    partition2.partition = 2;
    partition2.nHorizontalPartitions = 1;
    partition2.nVerticalPartitions = 2;
    partition2.mirror = 0;
    partition2.nFrames = 0;
    partition2.overlap = 0;
    
    partitions_train = [partition1 partition2];
end

% Check if used partitions exists.
if ~exist('partitions_dic', 'var')
    partitions_dic(1).partition = 1;
    partitions_dic(1).nHorizontalPartitions = 1;
    partitions_dic(1).nVerticalPartitions = 2;
    partitions_dic(1).mirror = 0;
    partitions_dic(1).nFrames = 0;
    partitions_dic(1).overlap = 0;
    
    partitions_dic(2).partition = 2;
    partitions_dic(2).nHorizontalPartitions = 1;
    partitions_dic(2).nVerticalPartitions = 2;
    partitions_dic(2).mirror = 0;
    partitions_dic(2).nFrames = 0;
    partitions_dic(2).overlap = 0;
    
    partitions_dic(3).partition = 1;
    partitions_dic(3).nHorizontalPartitions = 1;
    partitions_dic(3).nVerticalPartitions = 2;
    partitions_dic(3).mirror = 1;
    partitions_dic(3).nFrames = 0;
    partitions_dic(3).overlap = 0;
    
    partitions_dic(4).partition = 2;
    partitions_dic(4).nHorizontalPartitions = 1;
    partitions_dic(4).nVerticalPartitions = 2;
    partitions_dic(4).mirror = 1;
    partitions_dic(4).nFrames = 0;
    partitions_dic(4).overlap = 0;
end
