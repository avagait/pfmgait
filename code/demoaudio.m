% Demo for audio-based gait recognition
%
% See Castro et al., CAIP'2015
%
% (c) MJMJ/2015

%addpath(genpath(pwd));
disp('** This demo shows how to extract a global audio descriptor and classify it. **');

if ~exist('vl_version', 'file')
   error('Please, run "vl_setup" before calling this demo.');
end

%% Config for the database
dbname = 'tum';
mj_gaitLocalPaths;

extractAudioFeatures = false;        % CHANGE ME!

%% Extract audio features
if extractAudioFeatures
   if ~exist('miraudio' ,'file')
      error('Please, add "MIR toolbox" to Matlab�s path before calling this demo.');
   end
   
   whichFAud = [0 1 1 1];
   audiopars.sampling = 16000;
   aufile = './data/audio_p008_n05.wav';
   feats = mj_extractAudioFeats(aufile, whichFAud, audiopars);
end

%% Let's assume that you have already extracted audio features for the 
 % target video with the code provided in
 % http://www.uco.es/~in1majim/research/gait.html
mataudio = './data/p008_n05.mat';
load(mataudio); % Contains variable 'feats'

% Load dictionary for FV, already learnt
matdic = './data/full_dictionary_audio_K=0100';
load(matdic)

%% Compute PFM from loaded data
disp('Computing audio descriptor...');

audiodesc = dictionary.encode(feats);

disp(size(audiodesc))
clear feats

%% OPTIONAL: apply PCA compression if needed and classify
matsvm = 'full_model_audio_svmlin_K=0100_PCAH256_nFrames=0000_overlap=00.mat';
if exist(matsvm, 'file')   
   load(matsvm); model = model.model;
   disp('Compressing audio descriptor...');
   pcaobj = model.pcaobj;
   audioCompressed = pcaobj.encode(audiodesc');
   
   disp('Classifying audio descriptor...');
   labels_all = load('./data/tumgaidtestids.lst');
   labels_gt = mj_gaitLabFromName(dbname, mataudio);   
   [vidEstClass, svmscores, acc_test, acc_test_pc] = mj_classifyMultiClass(audioCompressed, labels_gt, model);
   
   fprintf('Estimated label for sample is %d with score %.4f \n', labels_all(vidEstClass), max(svmscores));
   if (labels_all(vidEstClass) == labels_gt)
      disp('Correct!');
   else
      disp('Failure');
   end     
   clear model pcaobj
end

