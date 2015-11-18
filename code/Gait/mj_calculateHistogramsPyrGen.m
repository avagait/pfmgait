function [histograms, labels, lfiles, id_videos] = mj_calculateHistogramsPyrGen(featuresPath, tracksPath, partitions, dictionary, cams, trajectories, sequences, kinddic, encpars)
% [histograms, labels, lfiles, id_videos] = mj_calculateHistogramsPyrGen(featuresPath, tracksPath, partitions, dictionary, cams, trajectories, kinddic, encpars)
% Multi-grid representation
% COMMENT ME!!!
%
% See also  fc_calculateHistograms, mj_decomposePartitionsPyr 
%
% (c) MJMJ/2013

% Versions:
%  - 26/Jun/2014: mjmarin, updated to use 'encpars'


l_partitions = mj_decomposePartitionsPyr(partitions);
histograms = [];
% Concatenate levels
for lpix = 1:length(l_partitions)
   [histograms_, labels, lfiles, id_videos] = mj_calculateHistogramsGen(featuresPath, tracksPath, l_partitions{lpix}, dictionary, cams, trajectories, sequences, kinddic, encpars);
   histograms = [histograms, histograms_];
end % lpix
