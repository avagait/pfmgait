function data = mj_extractAudioFeats(aufile, whichFAud, pars)
% data = mj_extractAudioFeats(aufile, whichFAud, pars)
% Extracts audio features from wav file
%
% Input:
%  - aufile: path to wav file
%  - whichFAud: booleans [Wave, Basic, MelSpectrum, MFCC]
%  - pars: struct with fields
%     .sampling: sampling rate. E.g. 16000
%
% Output:
%  - data: matrix [nfeats, nsamples]
%
% Requires: MIR audio toolbox >=1.5
%
% (c) MJMJ/2014


if ~exist('pars', 'var')   
   pars.sampling = [];
end

mirverbose(0);
amir = miraudio(aufile);

amir = miraudio(amir, 'Sampling', pars.sampling);
amirF = miraudio(amir, 'Frame');

data = [];

%% Audio wave
if whichFAud(1)
   data_ = mirgetdata(amirF);
   data = [data; data_];
end

%% Statistics
if whichFAud(2)
   zc = mirzerocross(amirF);
   dzc = mirgetdata(zc);
   
   kur = mirkurtosis(amirF);
   dkur = mirgetdata(kur);
   
   sk = mirskewness(amirF);
   dsk = mirgetdata(sk);
   
   fl = mirflatness(amirF);
   dfl = mirgetdata(fl);
   
   en = mirentropy(amirF);
   den = mirgetdata(en);
   
   
   data_ = [dzc; dkur; dsk; dfl; den];
   data = [data; data_];
end

%% Mel spectrum
if whichFAud(3)
   meldata = squeeze (mirgetdata(mirspectrum(amirF,'Mel')));
   data = [data; meldata'];
end

%% MFCC
if whichFAud(4)
   mfccdata = mirgetdata(mirmfcc(amirF));
   data = [data; mfccdata];
end

