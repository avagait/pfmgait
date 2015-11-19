% File: demodetect.m
% Detects people in video sequences.
%

videosdir = './data';
experdirbase = './data/tmp';
avifile = 'p005-n05.avi';       % CHANGE ME!
minArea = 1000;     % Minimum area of the BB. Adapt to your dataset.
aspectRatio = 3;    % Aspect ratio between width and height of the BB.
offset = 0.2;       % Percentage of increase of each dimension of the BB.
drawBB = true;     % Draw BB?

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
    mask = strel('square', 3);
    fgMask = imopen(fgMask, mask);
    % Find positions of the BB.
    [row, col] = find(fgMask / 255);
    if ~isempty(row) && ~isempty(col)
        x = min(col);
        y = min(row);
        x2 = max(col);
        y2 = max(row);
        BB_ = [x y x2 y2];
        % Omit small BBs.
        if (x2-x) * (y2-y) >= minArea
            % Normalize BB.
            det = zeros(size(BB_, 1), size(BB_, 2));
            for i=1:size(BB_, 1)
                x_cent = (BB_(i, 1) + BB_(i, 3)) / 2;
                y_cent = (BB_(i, 2) + BB_(i, 4)) / 2;
                height = BB_(i, 4) - BB_(i, 2);
                width = height / aspectRatio;
                height = height + (height * offset);
                width = width + (width * offset);
                det(i, 1) = x_cent - round(width / 2);
                det(i, 2) = y_cent - round(height / 2);
                det(i, 3) = x_cent + round(width / 2);
                det(i, 4) = y_cent + round(height / 2);
            end
            
            % Concatenate BBs of the whole sequence.
            imagePath = sprintf('%06d.png', nFrame);
            BBi = struct('image_path', imagePath, 'x', det(1), 'y', det(2), 'width', det(3)-det(1), 'height', det(4)-det(2), 'score', 1);
            BB = cat(1, BB, BBi);
        end
    end
    if drawBB
        imshow(frame); hold on
        title(sprintf('Frame %03d', nFrame));
        if ~isempty(row) && ~isempty(col)
            rec = [BBi.x, BBi.y, BBi.width, BBi.height];
            hr = rectangle('Position', rec);
            set(hr, 'EdgeColor', 'red');
            set(hr, 'LineWidth', 3);
        end
        pause(1.0/25);
    end
    
    nFrame = nFrame + 1;
end

release(videoSource);
output = fullfile(experdirbase, [videoname '.mat']);
save(output, BB);
fprintf('Writed file %s. \n', videoname);