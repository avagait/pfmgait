function I = InterpolateBBs(BB1, BB2)

% Interpolate between bounding-boxes BB1 and BB2,
% by adding an extra BB for every frame in BB1(1):BB2(1)
%
% BBs are considered rigid in aspect-ratio,
% so the (x,y) location of the center is interpolated linearly,
% and the scale is interpolated 'productrialy'.
%
% Input:
% BB = [frame_id min_x min_y width height scale score flip class pointer]'
%       with pointer being the pointer to the original D matrix entry for that class
% Only supports interpolation between two BBs of the same class.
%
% Output:
% I(:,ix) = interpolated bounding-boxes
%           (not including BB1 and BB2)
%

assert(BB1(9) == BB2(9), [mfilename ': can only interpolate between two bounding-boxes of the same class']);

% number of frames to interpolate over
% (length of the time gap between BB1 and BB2)
N = BB2(1)-BB1(1);
if N < 2
  I = [];
  return;
end

% interpolate BB center
ctr1 = BB1(2:3)+(BB1(4:5)/2);
ctr2 = BB2(2:3)+(BB2(4:5)/2);
dc = (ctr2-ctr1)/N;
C = repmat(ctr1,1,N-1) + repmat(dc,1,N-1).*repmat(1:(N-1),2,1);

% interpolate scale
% (could also use BB(6) directly,
% but I trust more the following measurement)
s1 = sqrt(BB1(4)*BB1(5));
s2 = sqrt(BB2(4)*BB2(5));
r = (s2/s1)^(1/N);
S = (ones(1,N-1)*s1) .* cumprod(ones(1,N-1)*r);
sfs = S ./ s1;                      % scale factors of new BBs wrt BB1

% construct output BBs
WH = [BB1(4)*sfs; BB1(5)*sfs];      % widths and heights of new BBs
Nh = floor((N-1)/2);                % number of interpolated frames which will take BB1's flip flag
I = [ ((BB1(1)+1):(BB2(1)-1)); C - WH/2; WH; sfs * BB1(6);  ones(1,N-1)*mean([BB1(7) BB2(7)]);  [ones(1,Nh)*BB1(8) ones(1,N-1-Nh)*BB2(8)]; ones(1,N-1)*BB1(9);  ones(1,N-1)*-1];
% scale (I(6,:)) of new dets is also a prod-interp of BB1(6) to BB2(6);
% score of new dets is the mean of scores of BB1 and BB2
% flip flag copied half from BB1 and half from BB1 (at this point everything should have been flipped already anyway)
% pointer (I(:,10)) set to -1, to mark these BBs do not come form the original D matrix for the class (i.e. have not been detected)
