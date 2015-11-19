% Demo for computing sparse tracklets for gait recognition
%
% See Marin-Jimenez et al. PRL'2015
%
% (c) MJMJ/2015

matfeats = './data/005-n-05_W01_H02.mat';
avifile = './data/p005-n05.avi';
load(matfeats); % Contains 'detections'

prcj = 0.5; % Percentage in (0,1]

%% Do the job
detectionsSel = mj_selectKeyDTs(detections, prcj);

fprintf('Selected a total of %d tracklets from %d \n', length(detectionsSel{1})+length(detectionsSel{2}), length(detections{1})+length(detections{2}));

clear detections

%% Visualization
[DT, lIds] = mj_combineDenseTracks(detectionsSel{1}, detectionsSel{2});

mj_displayDenseFeatsOnVideo(DT, avifile);

