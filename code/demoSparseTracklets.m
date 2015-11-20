% Demo for computing sparse tracklets for gait recognition
% and applying RootDCS descriptor.
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

%% Compute PFM with RootDCS features
% Load dictionary for FV, already learnt
matdic = './data/full_dictionary_K=0600.mat';
load(matdic)

disp('Computing PFM descriptor with RootDCS...');
% Define encoding parameters
pars.ftdims = [30 96 96 96]; % Default for DCS
pars.sqrt = [0 1 1 1]; % Default for RootDCS

% Convert to cell-array of DCS features
matrix = fc_calculateFeatsMatrix(detectionsSel, [1 2]);

% Fisher Vector encoding of DCS features: 
if iscell(matrix) % Several partitions
   pfm = [];
   for ixmt = 1:length(matrix)
      pfm_ = mj_encodeFV(matrix{ixmt}, dictionary, pars);
      pfm = [pfm; pfm_];
   end
else
   pfm = mj_encodeFV(matrix, dictionary, pars);
end

disp(size(pfm))
clear detectionsSel matrix
