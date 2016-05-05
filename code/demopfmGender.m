% Demo for Pyramidal Fisher Motion
%
% See Castro et al., ICPR'2014
%
% (c) MJMJ/2015

%addpath(genpath(pwd));
disp('** This demo shows how to extract a global gait descriptor and classify it. **');

if ~exist('vl_version', 'file')
   error('Please, run "vl_setup" before calling this demo.');
end

%% Config for the database
dbname = 'tum_gaid_gender';
mj_gaitLocalPaths;

extractGaitFeatures = false;        % CHANGE ME!

%% Extract motion features
if extractGaitFeatures
   % Run Jain's code
   demoExtractDT;
end

%% Let's assume that you have already computed dense tracks for the 
 % target video and applied tracking to the person with the code provided
 % in http://www.uco.es/~in1majim/research/gait.html
mattracks = './data/005-n-05_W01_H02.mat';
load(mattracks); % Contains variable 'detections'

% Load dictionary for FV, already learnt
matdic = './data/full_dictionary_K=0600.mat';
load(matdic)

%% Compute PFM from loaded data
disp('Computing PFM descriptor...');
% Define encoding parameters
pars = []; % Default

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
clear detections

%% OPTIONAL: apply PCA compression if needed and classify
matsvm = 'full_model_svmlin_K=0600_PCAH256_nFrames=0000_overlap=00_gender.mat';
if exist(matsvm, 'file')   
   load(matsvm); model = model.model;
   disp('Compressing PFM descriptor...');
   pcaobj = model.pcaobj;
   pfmCompressed = pcaobj.encode(pfm');
   
   disp('Classifying PFM descriptor...');
   labels_all = load('./data/allgender.txt');
   labels_gt = mj_gaitLabFromName(dbname, mattracks, labels_all);   
   [vidEstClass, svmscores, acc_test, acc_test_pc] = mj_classifyMultiClass(pfmCompressed, labels_gt, model);
   fprintf('Estimated label for sample is %d with score %.4f \n', labels_all(vidEstClass), max(svmscores));
   if (labels_all(vidEstClass) == labels_gt)
      disp('Correct!');
   else
      disp('Failure');
   end
   clear model pcaobj
end

