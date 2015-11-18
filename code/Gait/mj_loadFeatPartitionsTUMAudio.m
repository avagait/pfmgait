function totalFeatures = mj_loadFeatPartitionsTUMAudio(featuresPath, partitions, trajectories, sequences)
% totalFeatures = mj_loadFeatPartitions(featuresPath, partitions, cams, trajectories)
% This function is valid only for datasets with format similar to AVAMVG
% COMMENT ME!!!
% Input:
%   - featuresPath: input path
%   - partitions: struct-array
%   - cams: vector
%   - trajectories: vector
%
% Output:
%   - totalFeatures: struct-array with length == length(partitions)xlength(cams)xlength(trajectories)
%
% (c) MJMJ/2013
%
% MOD: mjmarin, 11/Dic/2013: added new option to join partitions into a single one

totalFeatures = [];
for i=1:length(partitions)
    for k=1:size(trajectories, 1)
        for l=1:size(sequences, 1)
            if partitions(i).mirror
                %pattern = sprintf('*tr%s_cam%s_W%02d_H%02d_M.mat', trajectories(k, :), cams(j, :), partitions(i).nHorizontalPartitions, partitions(i).nVerticalPartitions);
                pattern = sprintf('*_%s%s.mat', strtrim(trajectories(k, :)), sequences(l, :));
            else
                %pattern = sprintf('*tr%s_cam%s_W%02d_H%02d.mat', trajectories(k, :), cams(j, :), partitions(i).nHorizontalPartitions, partitions(i).nVerticalPartitions);
                pattern = sprintf('*_%s%s.mat', strtrim(trajectories(k, :)), sequences(l, :));
            end
            
            % Loading dense_feats and assigning their partitions, nFrames and overlap.
            features.feats = dir(fullfile(featuresPath, pattern));
            features.partition = partitions(i).partition;
            if isfield(partitions(i), 'join')
                features.join = partitions(i).join;
            else
                features.join = 0;
            end
            features.nFrames = partitions(i).nFrames;
            features.overlap = partitions(i).overlap;
            features.moreHorizontalPartitions = partitions(i).moreHorizontalPartitions;
            features.moreVerticalPartitions = partitions(i).moreVerticalPartitions;
            totalFeatures = [totalFeatures ; features];
        end % l
    end % k
end % i
