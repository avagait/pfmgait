function array = fc_fitFeatures(features, detections, grid, params)
% function array = fitFeatures(features, detections, grid, params)
% Fit the features of one person into its full body detections. The
% features that are out of the bounding-box are removed.
%
% If the parameter grid is defined, the features will be splitted according to
% the parts of the parameter.
%
% Input:
%  - features: Features of one person.
%  - detections: Full body detections of one person.
%  - grid: Structure with two parameters:
%       - horizontal: Array that contains the percentage limits of the parts in the
%         horizontal axis. For example: grid.horizontal = [0.4 0.6].
%       - vertical: Array that contains the percentage limits of the parts in the
%         vertical axis. For example: grid.vertical = [0.4 0.6].
%  - params: Structure with other parameters used in the algorithm:
%       - offset: Percentage offset of the detection.
%
% Output:
%  - array: Array that contains cells with the features of every part of
%  the detection. This array will contain as many cell as partitions
%  defined in the grid parameter.

% Useful variables
allFeatFrix = [features.frix];
allDetFrix = [detections.D(1, :)];
ndets = size(detections.D, 2);
ngh = length(grid.horizontal);
ngv = length(grid.vertical);

% Defining the size of the cell array.
array = cell(ngh * ngv, 1);
for i=1:ndets
    % Calculating width and height of the bounding-box with the offset.
    %width = detections.D(4, i) - detections.D(2, i)+1;
    %height = detections.D(5, i) - detections.D(3, i)+1;
    width = detections.D(4, i);
    height = detections.D(5, i);
    offset = width * params.offset * 0.01;
    width = width + (2 * offset);
    height = height + (2 * offset);
        
    % Find the features of the frame which has the current detection.
    %positions = find(extractfield(features, 'frix') == detections.D(1, i));
    positions = find(allFeatFrix == allDetFrix(i));
    for j=1:length(positions)
        found = 0;
        x = detections.D(2, i) - offset;
        
        % Crossing the parts of the horizontal axis.
        for k=1:ngh
            y = detections.D(3, i) - offset;
            x2 = (width * grid.horizontal(k)) + x;
            
            % If we are in the last part, we have to add the offset.
            if k == ngh %|| k == 1
                x2 = x2 + offset;
            end
            
            % Crossing the parts of the vertical axis.
            for l=1:ngv
                y2 = (height * grid.vertical(l)) + y;
                
                % If we are in the last part, we have to add the offset.
                if l == ngv %|| l == 1
                    y2 = y2 + offset;
                end
                
                % If the trajectory is inside the bounding-box or the
                % current partition, we save it.
                if fc_checkTrajectory(x, y, x2, y2, features(positions(j)))
                    array{k * l} = [array{k * l} features(positions(j))];
                    found = 1;
                    break;
                end
                
                % The end of the last part is the begin of the new part.
                y = y2;
            end
            
            % If we know the partition of the trajectory, we don't have to
            % cross the rest of loops.
            if found == 1
                break;
            end
            % The end of the last part is the begin of the new part.
            x = x2;
        end
    end
end