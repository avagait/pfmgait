function timePartitions = mj_calculateTimePartition(features, nFrames, overlap, onlyCentral)
% timePartitions = fc_calculateTimePartition(features, nFrames, overlap, onlyCentral)
% Split a track of features into partitions of nFrames.
%
% Input: 
%  - features: list of features of the track.
%  - nFrames: size of every partition.
%  - overlap: number of frames of overlap.
%  - onlyCentral: boolean
%
% Output:
%  - timePartitions: 2 dimensions array with features. Every row is one
%  partition.
%
% Based on fc_calculateTimePartition

if ~exist('onlyCentral', 'var')
   onlyCentral = 0;
end

%% Useful variables
lframes = [features.frix];
uframes = unique(lframes);
%nuframes = length(uframes);

%% Init vars
i = 1;
stepf = nFrames - overlap;

frix_pos = uframes(1):stepf:uframes(end);
nparts = length(frix_pos);

%% Loop over data
if ~onlyCentral
   timePartitions = cell(1, nparts); %{};
   for frix = frix_pos
      idx = and([lframes >= frix], [lframes < frix+nFrames]);
      
      %partition = [features(idx)];
      
      % Store data
      timePartitions{i} = [features(idx)]; %partition;
      i = i + 1;
   end % frix
else
   frix = frix_pos(ceil(length(frix_pos)/2));
   idx = and([lframes >= frix], [lframes < frix+nFrames]);
   
   % Store data
   timePartitions{1} = [features(idx)];
end % if

%    %% OLD CODE
% finish_i = false;
% i = 1;
% while ~finish_i
%     if ~isempty(timePartitions)
%         firstFrame = features(i).frix - overlap+1;
%     else
%         firstFrame = features(i).frix;
%     end
%     
%     lastFrame = firstFrame + nFrames;
%     if lastFrame > features(end).frix
%         firstFrame = features(end).frix - nFrames;
%         lastFrame = features(end).frix;
%         finish_i = true;
%     end
%     
%     partition = [];
%     finish_j = false;
%     j = 1;
%     while ~finish_j
%         if j <= length(features)
%             if features(j).frix >= firstFrame && features(j).frix <= lastFrame
%                 partition = [partition features(j)];
%             elseif features(j).frix > lastFrame
%                 finish_j = true;
%                 i = j - 1;
%             end
%             j = j + 1;
%         else
%             finish_j = true;
%         end
%     end
% 
%     timePartitions{end + 1} = partition;
%     i = i + 1;
% end
