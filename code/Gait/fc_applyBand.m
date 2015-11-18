function newTracks = fc_applyBand(tracks)
% function newTracks = fc_applyBand(tracks)
% Generate new dense tracks simulating a random mask where there are no
% trajectories. Two masks are used, one in the first part of the video and
% the other in the second part.
%
% Input:
%  - tracks: Filtered tracks.
%
% Output:
%  - newTracks: Array with the new tracks.
%

newTracks = tracks;

%% Get useful data.
frames = [tracks.frix];
% Frames where apply the mask.
minframe = min(frames);
maxframe = max(frames);
if (minframe + 2) >= maxframe
    frame1 = minframe;
    frame2 = minframe;
    frame11 = minframe;
    frame12 = minframe;
    frame21 = minframe;
    frame22 = minframe;
else
    frame1 = randi([minframe round((maxframe - minframe) / 2) + minframe], 1);
    frame2 = randi([round((maxframe - minframe) / 2)+1+minframe maxframe], 1);
    frame11 = frame1 - 15;
    frame12 = frame1;
    frame21 = frame2 - 15;
    frame22 = frame2;
end

%% Apply mask.
% Get tracks in the affected frames.
affectedTracks = tracks(frames >= frame11 & frames <= frame12);
newTracks(frames >= frame11 & frames <= frame12) = [];

% Get x and y.
feats = [affectedTracks.feats];
frames2 = [affectedTracks.frix];
x = feats(1:2:29, :);
y = feats(2:2:30, :);

% Min values.
minx = min(min(x));
miny = min(min(y));

% Max values.
maxx = max(max(x));
maxy = max(max(y));

% Random position of the mask.
x1 = (maxx - minx) * rand() + minx;
x2 = (maxx - x1) * rand() + x1;
y1 = (maxy - miny) * rand() + miny;
y2 = (maxy - y1) * rand() + y1;

for i=1:length(affectedTracks)
    % If the trayectory pass through the mask, we remove it.
    fx = frame1 - frames2(i) + 1;
    if affectedTracks(i).feats((2*fx)-1) >= x1 && affectedTracks(i).feats((2*fx)-1) <= x2 ...
            && affectedTracks(i).feats(2*fx) >= y1 && affectedTracks(i).feats(2*fx) <= y2
        newTracks = cat(2, newTracks, affectedTracks(i));
    end
end

if (maxframe - minframe) > 30
    %% Apply mask.
    % Get tracks in the affected frames.
    affectedTracks = tracks(frames >= frame21 & frames <= frame22);
    newTracks([newTracks.frix] >= frame21 & [newTracks.frix] <= frame22) = [];

    % Get x and y.
    feats = [affectedTracks.feats];
    frames2 = [affectedTracks.frix];
    x = feats(1:2:29, :);
    y = feats(2:2:30, :);

    % Min values.
    minx = min(min(x));
    miny = min(min(y));

    % Max values.
    maxx = max(max(x));
    maxy = max(max(y));

    % Random position of the mask.
    x1 = (maxx - minx) * rand() + minx;
    x2 = (maxx - x1) * rand() + x1;
    y1 = (maxy - miny) * rand() + miny;
    y2 = (maxy - y1) * rand() + y1;

    for i=1:length(affectedTracks)
        % If the trayectory pass through the mask, we remove it.
        fx = frame2 - frames2(i) + 1;
        if affectedTracks(i).feats((2*fx)-1) >= x1 && affectedTracks(i).feats((2*fx)-1) <= x2 ...
                && affectedTracks(i).feats(2*fx) >= y1 && affectedTracks(i).feats(2*fx) <= y2
            newTracks = cat(2, newTracks, affectedTracks(i));
        end
    end
end