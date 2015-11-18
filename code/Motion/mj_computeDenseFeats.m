function outfeatfile = mj_computeDenseFeats(videosdirbase, experdirbase, videoname, subject, extrapars, mirror, del, inter)
% outfeatfile = mj_computeDenseFeats(videosdirbase, experdirbase, videoname, subject, extrapars)
% Computes dense features by using Jain's binaries. 'DenseTrack' binary is required
%
% Input:
%  - videosdirbase: path to directory with videos
%  - experdirbase: path to directory where output will be saved
%  - videoname: name of video to be processed
%  - subject: used as subdirectory
%  - extrapars: struct with fields
%     .binpath
%     .binparams
%  - mirror: true to process mirror sequence
%  - del, inter. Def. false
%
% Output:
%  - outfeatfile: path to output file
%
% (c) MJMJ/2013

% VERSIONS:
%  - 10/April/2014, mjmarin: new output


if ~exist('extrapars','var')
   extrapars = [];   
end

if ~exist('del', 'var')
   del = 0;
end

if ~exist('inter', 'var')
   inter = 0;
end

if isempty(extrapars)
   extrapars.binpath = '~/libs/wFlow_dense_trajectory_release_v1.0/release';
   extrapars.binparams = '-T 0 -C 1';
end

% if ~exist('subject','var')
%    subject = 'manu';
% end

if ispc
   disp('Only for Linux'); %error('Only for Linux');
end

binpath = extrapars.binpath;


videosdir = fullfile(videosdirbase, subject);
experdir = fullfile(experdirbase, subject);

avifile = fullfile(videosdir, [videoname '.avi']);
outdir = fullfile(experdir, videoname);

exe = fullfile(binpath, 'DenseTrack');

%% Firstly, compute affine matrix

if mirror == 1
   if del > 0
       aux = sprintf('%s%d%s', '.wFlowT0C1F1D', del, '.features');
       outfeatfile = fullfile(outdir, [videoname aux '.gz']);
       outmat = fullfile(outdir, [videoname aux '.mat']);
   elseif inter > 0
       aux = sprintf('%s%d%s', '.wFlowT0C1F1I', inter, '.features');
       outfeatfile = fullfile(outdir, [videoname aux '.gz']);
       outmat = fullfile(outdir, [videoname aux '.mat']);
   else
       outfeatfile = fullfile(outdir, [videoname '.wFlowT0C1F1.features.gz']);
       outmat = fullfile(outdir, [videoname '.wFlowT0C1F1.features.mat']);
   end
else
   if del > 0
       aux = sprintf('%s%d%s', '.wFlowT0C1D', del, '.features');
       outfeatfile = fullfile(outdir, [videoname aux '.gz']);
       outmat = fullfile(outdir, [videoname aux '.mat']);
   elseif inter > 0
       aux = sprintf('%s%d%s', '.wFlowT0C1I', inter, '.features');
       outfeatfile = fullfile(outdir, [videoname aux '.gz']);
       outmat = fullfile(outdir, [videoname aux '.mat']);
   else
       outfeatfile = fullfile(outdir, [videoname '.wFlowT0C1.features.gz']);
       outmat = fullfile(outdir, [videoname '.wFlowT0C1.features.mat']);
   end
end

if exist(outmat, 'file')
   disp(['WARN: file ' outmat ' already exists. Skipping!']);
   return
end

if mirror == 1
  exeparamsaff = ' -M 1 -F 1';
else
  exeparamsaff = ' -M 1';
end

cmd1 = [exe ' ' avifile ' ' outdir ' ' exeparamsaff ];

ret = system(cmd1);

%% Now, compute dense points and features
binparams = extrapars.binparams;
exeparams = [' ' binparams ' | gzip > ' outfeatfile];

cmd2 = [exe ' ' avifile ' ' outdir ' ' exeparams ];

ret2 = system(cmd2);

%% Delete temporal files
ret3 = system(['rm ' fullfile(outdir, '*.png')]);
