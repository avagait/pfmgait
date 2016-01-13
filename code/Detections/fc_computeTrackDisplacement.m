function [total_x, avg_x, total_y, avg_y] = fc_computeTrackDisplacement(track)
%
%  - track: matrix where each column is [frame_id min_x min_y width height scale score 2]'
%

total_x = track(2, :) +  track(4, :)/2; %((track(4, :) - track(2, :)) / 2);
total_x = diff(total_x);
total_x = sum(total_x);
avg_x = total_x / size(track, 2);

total_y = track(3, :) +  track(5, :)/2; %((track(5, :) - track(3, :)) / 2);
total_y = diff(total_y);
total_y = sum(total_y);
avg_y = total_y / size(track, 2);