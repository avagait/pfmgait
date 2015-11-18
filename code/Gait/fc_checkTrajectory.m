function T = fc_checkTrajectory(x, y, x2, y2, trajectory)
% function T = checkTrajectory(x, y, x2, y2, trajectory)
% Check if a trajectory is contained in the rectangle composed by the
% points received as parameters.
%
% Input:
%  - x: Upper left point in the horizontal axis.
%  - y: Upper left point in the vertical axis.
%  - x2: Lower right point in the horizontal axis.
%  - y2: Lower right point in the vertical axis.
%  - trajectory: Trajectory of the motion flow.
%
% Output:
%  - T: True if the trajectory is contained in the rectangle or false if
%  not.

% Calculating the possible position of the point according to the variance.
tX = trajectory.mean(1) - trajectory.var(1);
tY = trajectory.mean(2) - trajectory.var(2);
tX2 = trajectory.mean(1) + trajectory.var(1);
tY2 = trajectory.mean(2) + trajectory.var(2);

% Areas.
area1 = (x2 - x) * (y2 - y);
area2 = (tX2 - tX) * (tY2 - tY);

% Intersections.
xxx1 = max(x, tX);
yyy1 = max(y, tY);
xxx2 = min(x2, tX2);
yyy2 = min(y2, tY2);
w = xxx2-xxx1+1;
h = yyy2-yyy1+1;
if w > 0 && h > 0
	overlap = w * h / min(area1, area2);
    if overlap > 0.5
        T = true;
    else
        T = false;
    end
else    
    T = false;
end