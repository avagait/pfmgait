% function scores = evaluateTracks(tracks, minFrames, offset)
% Evaluate tracks and set a score that is the sum of every score of a BB and  
% the offset.
% Input:
%  - tracks: Array of tracks.
%  - minFrames: Minimum number of frames.
%  - offset: Offset added to every BB score.
%
% Output:
%  - scores: Array of calculated scores.
%
% See also createBOWDictionary, vl_alldist2, vl_binsum
function scores = fc_evaluateTracks(tracks, minFrames, offset)

scores = zeros(1, length(tracks));
for i=1:length(tracks)
    if size(tracks(i).D, 2) >= minFrames
        for j=1:size(tracks(i).D, 2)
            scores(i) = scores(i) + tracks(i).D(7, j) + offset;
        end
    end  
end

