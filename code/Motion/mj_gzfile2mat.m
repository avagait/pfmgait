function matfile = mj_gzfile2mat(gzfile)
% matfile = mj_gzfile2mat(gzfile) 
% Extracts files from gzip and saves to mat
%
% (c) MJMJ/2014

[folder, bname, ext] = fileparts(gzfile);

% Check if already exists mat
matfile = fullfile(folder, [bname '.mat']);
if exist(matfile, 'file')
   return
end

outdir = folder; %fullfile(experdir, videoname);
% Unzip
gunzip(gzfile, outdir);

% Load file
featstxt = fullfile(outdir, bname);
disp(['Loading file: ' featstxt]);
F = loadDenseFeatFile(featstxt);

% Save to mat
save(matfile, 'F');

% Delete extracted txt
if ispc
   system(['del ' featstxt]);
else
   system(['rm -f ' featstxt]);
end
