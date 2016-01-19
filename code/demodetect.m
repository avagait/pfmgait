% File: demodetect.m
% Detects people in video sequences.
%

videosdir = './data';
experdirbase = './data/tmp';
avifile = 'p005-n05.avi';       % CHANGE ME!
minArea = 1000;     % Minimum area of the BB. Adapt to your dataset.
aspectRatio = 3;    % Aspect ratio between width and height of the BB.
offset = 0.2;       % Percentage of increase of each dimension of the BB.
drawBB = false;     % Draw BB?

if ~exist(experdirbase, 'dir')
   mkdir(experdirbase);
end

%% Run it!
[folder, videoname, ext] = fileparts(avifile);
BB = [];
videoSource = vision.VideoFileReader(fullfile(videosdir, avifile) ,'ImageColorSpace','Intensity','VideoOutputDataType','uint8');
detector = vision.ForegroundDetector(...
    'NumTrainingFrames', 40, ...
    'InitialVariance', 30*30, 'NumGaussians', 10); % initial standard deviation of 30
nFrame = 1;
while ~isDone(videoSource)
    % Apply an aperture to normalize the segmentation.
    frame  = step(videoSource);
    fgMask = step(detector, frame);
    
    % Concatenate BBs of the whole sequence.
    BBi = fc_getBBWithSegmentation(fgMask, minArea, aspectRatio, offset, nFrame);
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
