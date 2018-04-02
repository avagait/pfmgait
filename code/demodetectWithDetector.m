% File: demodetectWithDetector.m
% Detects people in video sequences.
% Object detection system using deformable part models (DPMs) and latent SVM (voc-release4.01) is required.
% The model of the the detector is included in voc-release.
%

disp('** This demo shows how to detect people in a video sequence **');

%% Configuration
videosdir = './data';
experdirbase = './data/tmp';
avifile = 'p008-n05.avi';       % CHANGE ME!
drawBB = true;     % Draw BB? Set to true to show frames with detections
detector = {'voc-release4.01/INRIA/inriaperson_final.mat'}; % CHANGE ME! Path to the detector.
class = 'FB-generic'; % Kind of detection.
detectionParameters = struct('iou_thresh', 0.5, 'det_thresh', 0.4); % iou_thresh -> Intersection over Union threshold. det_thresh -> minimum score of a detection.
verbose = 0;
addpath('/voc-release4.01'); % CHANGE ME!

if ~exist(experdirbase, 'dir')
    mkdir(experdirbase);
end

%% Run it!
[folder, videoname, ext] = fileparts(avifile);
BB = [];
videoSource = vision.VideoFileReader(fullfile(videosdir, avifile) ,'ImageColorSpace','Intensity','VideoOutputDataType','uint8');
nFrame = 1;
while ~isDone(videoSource)
    % Get new frame.
    frame  = step(videoSource);
    
    % Detection
    model = load(detector); model = model.model;
    [dets, ~] = imgdetect(frame, model, min(model.thresh, detectionParameters.det_thresh));
    if isempty(dets)
        bodies = [];
    else
        bodies = dets(:,[1:4 end-1 end]); 
    end
    
    if ~isempty(bodies)
        bodies = mj_filterDetsByScore(bodies, detectionParameters.det_thresh);
    end
    
    % NMS
    if ~isempty(bodies)
        pick = nms(bodies, 0.35);
        bodies = bodies(pick, :);
    end
    
    BBi = bodies;
    
    if ~isempty(BBi)
        BB = cat(1, BB, BBi);
        % Draw BB
        if drawBB
            imshow(frame); hold on
            title(sprintf('Frame %03d', nFrame));
            rec = [BBi.x, BBi.y, BBi.width, BBi.height];
            hr = rectangle('Position', rec);
            set(hr, 'EdgeColor', 'red');
            set(hr, 'LineWidth', 3);
            pause(1.0/25);
        end
    end
    nFrame = nFrame + 1;
end

release(videoSource);
output = fullfile(experdirbase, [videoname '-bb.mat']);
save(output, 'BB');
fprintf('Written file %s. \n', videoname);
