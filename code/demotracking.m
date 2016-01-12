% File: demotracking.m
% Tracking of the detections in a sequence.
%

videosdir = './data';
detectionsdir = './data';
experdirbase = './data/tmp';
detfile = 'p005_n05.mat';       % CHANGE ME!
outputname = '005-n-05_fb_tracks.mat';    % CHANGE ME!
ublibpath = '';     % Path to the library used for tracking.
minFrames = 0;      % Minimum number of frames that a track must have.
detectionOffset = 3; % Offset added to every BB score. Used to normalize
% scores between different detectors.
pars.time_stdv = 2; % Parameter used for tracking.
pars.cp_thresh = 0.2; % Parameter used for tracking.
metric = 'chisq'; % Metric for joining tracks.
joinThreshold = 15000; % Threshold for joining tracks.
nBeans = 16; % Number of components of the histograms.

%% Run it!
det = load(fullfile(detectionsdir, detfile));
det = det.detections;
% Building the matrix for the tracking process.
detections = zeros(10, length(det));
T = regexp(det(1).image_path, '/', 'split');
name = strcat(full_name{1}, '.avi');
for j=1:length(det)
    T = regexp(det(j).image_path, '/', 'split');
    T = regexp(T{1, length(T)}, '\.', 'split');
    
    detections(1, j) = str2double(T{1, 1});
    detections(2, j) = det(j).x;
    detections(3, j) = det(j).y;
    detections(4, j) = det(j).width;
    detections(5, j) = det(j).height;
    detections(6, j) = 1;
    detections(7, j) = det(j).score;
    detections(8, j) = 1;
    detections(9, j) = 2;
    detections(10, j) = 1;
end

% Remove nested detections?
detections = mj_filterInsideDets(detections);
shot = [detections(1, 1) detections(1, size(detections, 2))];

% Tracking.
ubpath = fullfile(ublibpath, 'ubtrack/matlab');
addpath(ubpath);
tracks = track(detections, shot, pars);
scores = fc_evaluateTracks(tracks, minFrames, detectionOffset);

% Interpolate tracks.
for j=1:length(tracks)
    tracks(j).D = InterpolateTrack(tracks(j).D);
    [total_x, avg_x, total_y, avg_y] = fc_computeTrackDisplacement(tracks(j).D);
    if (abs(total_x) + abs(total_y)) < 1
        scores(j) = 0;
    end
end

% Smooth tracks.
for trix = 1:length(tracks)
    tracks(trix).D(2:5,:) = me_smoothBB(tracks(trix).D(1,:)-tracks(trix).D(1,1),tracks(trix).D(2:5,:),3,2);
end

scoredTracks = struct('tracks', tracks, 'scores', scores);

if length(tracks) > 1
    scoredTracks = fc_joinTracks(fullfile(videosdir, name), scoredTracks, nBeans, metric, joinThreshold);
end

% Save results.
detections = scoredTracks;
output = fullfile(experdirbase, [outputname '.mat']);
save(output, 'detections');
fprintf('Writed file %s. \n', outputname);
