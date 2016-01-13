function Dout = InterpolateTrack(D)

% Interpolate sequence of detections BBs D,
% by adding virtual detections interpolated over every run
% of missing frames between every two detections.
%
% BBs are considered rigid in aspect-ratio,
% so the (x,y) location of the center is interpolated linearly,
% and the scale is interpolated 'productrialy'.
%
% Input:
% D(:,bbix) = [frame_id min_x min_y width height scale score 2]
%
% Output:
% Dout = extended D with additional detections
%

% find continuos runs of detections
% R{rix} = list of frames in rix-th run
R = ContRuns(D(1,:));

% interpolate between two runs
% mix = 'hole index' (inbetween runs mix and run mix+1)
Dout = [];
for mix = 1:(length(R)-1)
  %
  % get the two BBs to interpolate between
  run_bef = R{mix};             % run before the hole
  Dbef = D(:,run_bef(2,end));   % last detection BB before the hole
  run_aft = R{mix+1};           % run after the hole
  Daft = D(:,run_aft(2,1));     % first detection BB after the hole
  %
  % interpolate
  I = InterpolateBBs(Dbef,Daft);
  %
  % add to output
  Dout = [Dout D(:,run_bef(2,:)) I];
end
run_last = R{end};
Dout = [Dout D(:,run_last(2,:))];
