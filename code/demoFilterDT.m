% File: demoFilterDT.m
% Tracking of the detections in a sequence.
%
% See Castro et al., ICPR'2014

disp('** This demo shows how to filter out dense tracklets given people detections **');

%% Configuration
dtdir = './data';
trackdir = './data/tmp';
experdirbase = './data/tmp';
dtfile = 'p005-n05.wFlowT0C1.features.mat'; %'p005-n05.mat';       % CHANGE ME!
trackfile = '005-n-05_fb_tracks.mat';       % CHANGE ME!
outputname = '005-n-05_W01_H02.mat';    % CHANGE ME!
grid.horizontal = 1; % Array that contains the percentage limits of the
% parts in the horizontal axis.
grid.vertical = [0.5 0.5]; % Array that contains the percentage limits of the parts in the
% vertical axis.
params.offset = 0; % Percentage offset of the detection.
threshold = 50; % Minimum score of a track.

%% Run it!
% Loading features.
features = load(fullfile(dtdir, dtfile));
features = features.F;

% Loading tracks.
tracks = load(fullfile(trackdir, trackfile));
scores = tracks.detections.scores;
tracks = tracks.detections.tracks;

% Cleaning and saving tracks.
allFeatures = [];
for i=1:length(tracks)
    fprintf('score = %.2f\n', scores(i));
    if scores(i) > threshold
        finalFeatures = fc_fitFeatures(features, tracks(i), grid, params);
        allFeatures = [allFeatures ; finalFeatures];
    end
end

% Save results.
detections = allFeatures;
output = fullfile(experdirbase, outputname);
save(output, 'detections');
fprintf('Written file %s. \n', outputname);
