% File: downloadPFMData.m
% Downloads pretrained models used in the demos.
%
% (c) MJMJ/2016

outdir = 'data'; % CHANGE ME!!!

%% Audio classifier
filename = 'full_model_audio_svmlin_K=0100_PCAH256_nFrames=0000_overlap=00.mat';
if ~exist(filename, 'file')
   zipfile = 'svm_audio.zip';
   theURL = ['http://rabinf24.uco.es/gaitdata/' zipfile];      
   fprintf('+ Downloading file %s ...', zipfile);
   urlwrite(theURL, zipfile);
   unzip(zipfile, outdir);
   fprintf(' done!\n');
end

%% PFM-visual classifier
filename = 'full_model_svmlin_K=0600_PCAH256_nFrames=0000_overlap=00.mat';
if ~exist(filename, 'file')
   zipfile = 'svm_pfm.zip';
   theURL = ['http://rabinf24.uco.es/gaitdata/' zipfile];      
   fprintf('+ Downloading file %s ...', zipfile);
   urlwrite(theURL, zipfile);
   unzip(zipfile, outdir);
   fprintf(' done!\n');
end

%% PFM-depth classifier
filename = 'full_model_svmlin_K=0600_PCAH256_nFrames=0000_overlap=00_depth.mat';
if ~exist(filename, 'file')
   zipfile = 'svm_depth.zip';
   theURL = ['http://rabinf24.uco.es/gaitdata/' zipfile];      
   fprintf('+ Downloading file %s ...', zipfile);
   urlwrite(theURL, zipfile);
   unzip(zipfile, outdir);
   fprintf(' done!\n');
end

%% Gender classifier
filename = 'full_model_svmlin_K=0600_PCAH256_nFrames=0000_overlap=00_gender.mat';
if ~exist(filename, 'file')
   zipfile = 'svm_gender.zip';
   theURL = ['http://rabinf24.uco.es/gaitdata/' zipfile];      
   fprintf('+ Downloading file %s ...', zipfile);
   urlwrite(theURL, zipfile);
   unzip(zipfile, outdir);
   fprintf(' done!\n');
end

%% Shoes classifier
filename = 'full_model_rb_K=0600_PCAH256_nFrames=0000_overlap=00.mat';
if ~exist(filename, 'file')
   zipfile = 'rb_shoes.zip';
   theURL = ['http://rabinf24.uco.es/gaitdata/' zipfile];      
   fprintf('+ Downloading file %s ...', zipfile);
   urlwrite(theURL, zipfile);
   unzip(zipfile, outdir);
   fprintf(' done!\n');
end
