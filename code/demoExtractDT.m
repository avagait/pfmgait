% File: demoExtractDT.m
%
% (c) MJMJ/2015

disp('** This demo shows how to extract dense tracklets from a video sequence **');

%% Configuration
videosdir = './data';
experdirbase = './data/tmp';
avifile = 'p005-n05.avi';                       % CHANGE ME!
[folder, videoname, ext] = fileparts(avifile);

%% Config
extrapars.binpath = './libs/wFlow_dense_trajectory_release_v1.0/release'; % Set your path here
extrapars.binparams = '-T 0 -C 1';

%% Run it!
outdensefile = mj_computeDenseFeats(videosdir, experdirbase, videoname, '', extrapars, false, false, false);

if ~isempty(outdensefile) && exist(outdensefile, 'file')
   % Convert to mat file
   matdtfile = mj_gzfile2mat(outdensefile);
else
   matdtfile = '';
   warning('Something went wrong...','PFM:noOutputDenseTracksFile');
end

disp(['Output saved to :', matdtfile]);