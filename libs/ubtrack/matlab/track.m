function [T, bbixs] = track(D, shot, pars)

% track(D, shot, pars)
% Track detection bounding-boxes between frame shot(1) and shot(2).
%
% Input:
% - D(:,i) = [frame_id min_x min_y width height scale score 2]
%          = matrix with all detections over all frames (ordered by frame id)
%
% - pars   = parameters
%   pars.time_stdv = magnitude of time damping (2 is a good value)
%   pars.cp_thresh = pos/neg splitting point for clustering (0.2 is a good value)
% 
% - shot = [fr_begin fr_end]' = over which frames to track
%
%
% Output:
% - T(k).D(:,i) = detections grouped into a track k.
%
% - bbixs = list of indeces in D(:,i) for all detections in the shot
%
% Authors:
% V. Ferrari and M.J. Marin
%

% find first and last detections (within D) for this shot
bbix_begin = find(D(1,:) >= shot(1),1);
bbix_end = find(D(1,:) > shot(2),1) - 1;
if isempty(bbix_end)
  bbix_end = size(D,2);
end

% convert dets to format [min_x min_y max_x max_y]' (expected by all_pairs_bb_iou)
% also don't -1 to max_x and max_y, to allows for the 1-pixel wide concept
% so all_pairs_bb_iou returns the correct result considering a det of width
% 1 starts and ends at the same pixel
bbixs = bbix_begin:bbix_end;
BBs = D(2:5,bbixs);
BBs(3:4,:) = BBs(1:2,:) + BBs(3:4,:);

% compute overlap/union for all pairs of BBs
% to save memory, put everything into weight matrix for CP
% right from the start
W = all_pairs_bb_iou(BBs, BBs) - pars.cp_thresh;

% compute time-damping factor for all pairs of BBs
tbb = D(1,bbix_begin:bbix_end);
Dt = tbb' * ones(1,length(tbb));
Dt = Dt - Dt';
same_fr = (Dt == 0);                                      % for later enforcing constr of not grp BBs from same frm (done this way for economy of memory)
Dt = exp(- (abs(Dt)-1).^2 / pars.time_stdv^2 );

% update edge weights for CP
W = W .* Dt;

% don't group two BBs from the same frame
W(same_fr) = -inf;

% save memory
clear Dt;

% cluster by Clique Partitioning (CP)
tic;
W = single(W);                                            % memory saving
disp('Running Clique Partitioning');
C = CP(W);                                            
clear W;
C = SortC(C);                                             % sort in descending size of clusters

% convert C to output T
T = [];                                                   % support case where no BBs in this shot
for cix = 1:length(C)                  
  uix = bbixs(C(cix).list);
  uix = sort(uix);                                        % sort them by ascending bbix -> increasing time order
  T(cix).D = D(:,uix);  
end
