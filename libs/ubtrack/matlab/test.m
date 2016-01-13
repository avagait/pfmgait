% top-level script to test detection and tracking of upper-bodies
%
% Make sure to start from the directory containing 'test_video' and 'HoG' !
%

% setup parameters for tracking
bb_track_params.time_stdv = 2;
bb_track_params.cp_thresh = 0.2;

% setup colors for drawing
global colors;
colors = rand(50,3);

% detect in every frame of the video
D = detect([pwd '/test_video'], [pwd '/HoG'], 'jpg');

% associate detections over time
T = track(D, [24300 24470], bb_track_params);

% draw resulting tracks
draw_tracks([pwd '/test_video'], '%06d.jpg', T);
