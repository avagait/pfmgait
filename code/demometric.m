% Demo for using metric learning on gait descriptors.
%
% See Marin-Jimenez et al. PRL'2015
%
% (c) MJMJ/2015

disp('** This demo shows how to compress PFM descriptors. **');

matfeats = './data/005-n-05_W01_H02.mat';
load(matfeats); % Contains variable 'detections'

mlmodel = 'classunreg';
matmetric = './data/ml_modelC0064_K=0256_nFrames=0000_overlap=00_W0_sq.mat';
load(matmetric); % Contains variable 'model'

%% Compute PFM
% Load dictionary for FV, already learnt
matdic = './data/full_dictionary_K=0256.mat';
load(matdic);

disp('Computing PFM descriptor...');
% Define encoding parameters
pars.ftdims = [30 96 96 96]; % Default for DCS
pars.sqrt = [0 1 1 1]; % Default for RootDCS

% Convert to cell-array of DCS features
matrix = fc_calculateFeatsMatrix(detections, [1 2]);

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
clear detections matrix dictionary

%% Apply metric
disp('Projecting PFM descriptor with Metric Learning...');
% Prepare parameters
W = model.state.W;    % Projection matrix
b = model.state.b;    % Bias for verification application

% Whitening, if needed
[pfmWhite, wM_, wP_] = mj_zcaWhite(pfm', 1e-05, model.wM, model.wP);

pfmProj = W * pfmWhite';
disp(size(pfmProj))

%% Binarization
disp('Compressing PFM descriptor with binarization...');
binDims = 2048;
% Generate a random matrix
featDims = length(pfmProj);
B = mj_binCompressV(binDims, featDims);
model.B = B;
% Binarize using the new matrix 
% Removing the mean vector (learnt from prototypes) before binarization helps
pfmBin = mj_binarizeV(pfmProj, B);


infoP = whos('pfmProj');
infoB = whos('pfmBin');
fprintf('* PFM descriptor after proyection uses %d Bytes, whereas the binarized one uses %d bits \n', infoP.bytes, length(pfmBin));
