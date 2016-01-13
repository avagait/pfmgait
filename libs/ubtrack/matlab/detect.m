function D = detect(frames_dir, hog_dir, img_type)

% detect(frames_dir, hog_dir, img_type)
% Detects objects in all images in directory frames_dir
%
% Input:
%   - frames_dir contains images whose filenames end in ['.' img_type] (e.g. img_type = 'jpg')
%     best use absolute path (i.e. starting from '/' under Unix)
%
%   - hog_dir is the directory where the HoG detector binaries are installed
%     best use absolute path (i.e. starting from '/' under Unix)
%
% Output:
%   - D(:,i): each column of D represents a different detection, in the format
%             [frame_id min_x min_y width height scale score 2]'
%
% Authors:
% V. Ferrari and M.J. Marin
%

org_dir = pwd;

% the shell script to invoke the HoG detector
% currently set to the upper-body frontal
% (change here to detect other kinds of objects)
det_script = [hog_dir '/detect_upperbodyH90.sh'];

dets_dir = [frames_dir '_dets'];                                % dir with overlaid detected BBs
det_BBbase = '_dets.txt';                                       % detections in text format (one file per frame)

mkdir(dets_dir);
cd(frames_dir);
frames = dir(['*' img_type]);

fprintf(' %d frames\n\n', length(frames));

fnum = 0;
for fr = frames'
  fnum = fnum + 1;
  fprintf(' --> Frame: %d of %d \n', fnum, length(frames));
  basename = fr.name(1:(end-length(img_type)-1));
  det_file = [dets_dir '/' basename det_BBbase];
  system([det_script ' ' frames_dir '/' fr.name ' ' det_file ' ' dets_dir '/' fr.name ' ' hog_dir]);
end


% assemble global detection matrix D for the entire video
% format of one line of HoG dets BBs file is
% min_x min_y width height scale score 2
% and 0s at the beginning of each frame
% output format here instead is:
% one detection per column, each column is:
% [frame_id min_x min_y width height scale score 2]'
% No 0s lines as in original HoG
cd(dets_dir);
frames = dir(['*' det_BBbase]);
% preallocate on a generous average of 10 dets per frame
% if more there, just goes slowly as it reallocs D with every addition
D = zeros(10*length(frames),8);
dix = 0;                                        % index of latest added detection
for fr = frames'
  fr_id = LastInteger(fr.name);
  temp = load(fr.name);
  if size(temp,1) > 1                           % at least one detection ?
    temp = temp(2:end,:);                       % strip off initial 0s line
    n = size(temp,1);
    D((dix+1):(dix+n),:) = [fr_id*ones(n,1) temp];
    dix = dix + n;
  end
end
% strip away trailing 0s rows
D = D(1:dix,:);
% convert to column format
D = D';

cd(org_dir);

