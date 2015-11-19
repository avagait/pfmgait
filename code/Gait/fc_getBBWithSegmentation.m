function BB = fc_getBBWithSegmentation(fgMask, minArea, aspectRatio, offset, nFrame)
% mj_drawDetection(bb, score, dtcolor)
%
% Input:
%  - fgMask: frame segmented.
%  - minArea: minimum area of the BB.
%  - aspectRatio: aspect ratio between width and height of the BB.
%  - offset: percentage of increase of each dimension of the BB.
%  - nFrame: current frame.
%
% Output:
%  - BB: bounding box.
%      - image_path.
%      - x
%      - y
%      - width
%      - height
%      - score
%

% Apply an aperture to normalize the segmentation.
mask = strel('square', 3);
fgMask = imopen(fgMask, mask);
% Find positions of the BB.
[row, col] = find(fgMask / 255);
BB = [];
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
        
        % Build BB structure.
        imagePath = sprintf('%06d.png', nFrame);
        BB = struct('image_path', imagePath, 'x', det(1), 'y', det(2), 'width', det(3)-det(1), 'height', det(4)-det(2), 'score', 1);
    end
end