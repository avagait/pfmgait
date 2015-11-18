function [T, frames] = mj_recoverDTfromFeats(DT)
% [T, frames] = mj_recoverDTfromFeats(DT)
% Given DT descriptors, this function recovers the original (x,y) trajectories.
% WARNING: this function assumes that tracklets were computed over 15 frames
% Input:
%  - DT: struct-array of dense tracklets with fields
%     .len
%     .mean
%     .feats
%
% Output:
%  - T: matrix [2, 16, nfeats], where T(:,i,fix) = [x_i,y_i]'.
%  - frames: first frame of each trajectory.
%
% (c) MJMJ/2014



nfeats = length(DT);
T = zeros(2, 16, nfeats);
frames = zeros(nfeats, 1);

for fix = 1:nfeats
   
   mn = DT(fix).mean;
   trj = DT(fix).feats(1:30);
   
   % Recover original trajectory
   trj = trj*DT(fix).len;
   
   xn = trj(1:2:end);
   yn = trj(2:2:end);
   x = [mn(1)];
   y = [mn(2)];
   for i = 1:length(xn)
      x = [x, x(end)+xn(i)];
      y = [y, y(end)+yn(i)];
   end
   
   x = x - (mean(x)-mn(1));
   y = y - (mean(y)-mn(2));
   
   T(1,:, fix) = x;
   T(2,:, fix) = y;
   frames(fix) = DT(fix).frix;
end % fix