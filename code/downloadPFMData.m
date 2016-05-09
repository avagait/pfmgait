% File: downloadPFMData.m
% Downloads pretrained models used in the demos.
%
% (c) MJMJ/2016

outdir = 'data'; % CHANGE ME!!!

%% Audio classifier
filename = 'full_model_audio_svmlin_K=0100_PCAH256_nFrames=0000_overlap=00.mat';
if ~exist(filename, 'file')
   zipfile = 'svm_audio.zip'
   theURL = ['http://rabinf24.uco.es/gaitdata/' zipfile];      
   fprintf('+ Downloading file %s ...', zipfile);
   urlwrite(theURL, zipfile);
   unzip(zipfile, outdir);
   fprintf(' done!\n');
end

%% Identify classifier
filename = 'full_model_svmlin_K=0600_PCAH256_nFrames=0000_overlap=00.mat';
if ~exist(filename, 'file')
   zipfile = 'svm_pfm.zip'
   theURL = ['http://rabinf24.uco.es/gaitdata/' zipfile];      
   fprintf('+ Downloading file %s ...', zipfile);
   urlwrite(theURL, zipfile);
   unzip(zipfile, outdir);
   fprintf(' done!\n');
end