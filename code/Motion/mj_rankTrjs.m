function [R, E, oix] = mj_rankTrjs(T)
% [R, E, oix] = mj_rankTrjs(T)
% COMMENT ME!!!
% Rank trajectories based on their difference wrt median velocities
%
% Input:
%  - T: matrix [2, nframes, ntracks]
%
%
% Output:
%  - R: sorted Trajectories matrix [2, nframes, ntracks]
%  - E: vector with energies of T (higher energy is better)
%
% (c) MJMJ/2014

R = [];
E = [];
oix = [];

ntracks = size(T,3);

if ntracks < 2
   return
end

%% Compute velocities
V = diff(T,1,2);              % Velocity vectors
M = squeeze(sqrt(sum(V.^2))); % Magnitude

%% Median velocity at given time 
nframes = size(M,1);
Md = zeros(nframes,2);
for pix = 1:nframes
   %md(pix) = median(M(pix,:));
   Md(pix,1) = median(V(1,pix,:));
   Md(pix,2) = median(V(2,pix,:));
end % pix

Vn = V - repmat(Md', [1 1 size(V,3)]);

% Magnitude of vector difference
Mn = squeeze(sqrt(sum(Vn.^2))); % Magnitude

% Accumulate along time to find anchors
cMn = sum(Mn);

% Sort (first ones are anchor candidates)
[oMn, oix] = sort(cMn, 'descend');

%% Output
R = T(:,:,oix);
E = cMn ./ nframes;
