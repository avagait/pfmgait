function draw_tracks(frames_dir, fname_format, T)

% draw_tracks(frames_dir, format, T)
%
% Draw tracks T(k).bbixs overlaid on images in frames_dir.
%
% Detections belonging to the same track are drawn in the same color.
%
% Detection scores are drawn in the same color as the detection bounding-box.
%
% If pars.draw_track_id given
% -> draw also track id in the BB: good when there are more tracks than different colors.
%
% Input:
% - frames_dir contains images whose filenames follow fname_format
%   (standard printf formatting); best use absolute path (i.e. starting
%   from '/' under Unix)
% 
% - T(k).D are tracks as output by track.m
%
% Authors:
% V. Ferrari and M.J. Marin
%

% find first and last frames over all tracks
temp = [T.D];
min_fr = min(temp(1,:));
max_fr = max(temp(1,:));

% re-organize the tracks framewise
F = zeros(length(T), max_fr+1);
for tix = 1:length(T)
  frs = T(tix).D(1,:);                                 % frames in which T(tix) appears
  F(tix,frs+1) = 1:length(frs); 
end

% draw BBs over each frame in turn
% a different color per BB
h = figure;
for fr = min_fr:max_fr

  % load and display frame
  fname = sprintf(fname_format, fr);                   % frame filename
  im = imread([frames_dir '/' fname]);                 % load frame
  clf(h); imshow(im);                                  % display frame (clf -> speed)
 
  % draw BBs for all tracks appearing in this frame
  for tix = find(F(:,fr+1))'
    bb = T(tix).D(2:7,F(tix,fr+1))'; 
    % cycle colors if more tracks than colors
    draw_bb([bb(1) bb(1)+bb(3)-1 bb(2) bb(2)+bb(4)-1], tix, 3, bb(6), tix);
  end % loop over tracks appearing in this frame
  drawnow;                                             % make sure you see something ;)
 
end
