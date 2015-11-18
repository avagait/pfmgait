function detectionsSel = mj_selectKeyDTs(detections, prcj)
% detectionsSel = mj_selectKeyDTs(detections)
% COMMENT ME!!!
% Selection of tracklets based on median motion
%
% Input:
%  - detections: cell-array of dense trajectories descriptors
%  - prcj: real value in [0,1] , e.g. 0.3, or a threshold (NEGATIVE value to
%  activate it, e.g. -2.1 , but absolute value is used (i.e. 2.1 ) to keep
%  tracks with energy above it.
%
% Ouput:
%  - detectionsSel: cell-array of selected DTs
%
%
% (c) MJMJ/2014
%
% MOD, mjmarin, April/2015: prcj can be a threshold

assert(prcj <= 1.0);

thrmode = false;
if prcj < 0
   thrmode = true;
   prcj = abs(prcj);
end

multiParts = length(detections) > 1;

if multiParts

  [DT, lIds] = mj_combineDenseTracks(detections{1}, detections{2});
else
   DT = detections;
end

frames = [DT.frix];
uframes = unique(frames);
nframes = length(uframes);
%lastframe = uframes(end);

lR = [];
lSelIds = [];
lE = [];

for ix = 1:nframes,
   clf
   frix = uframes(ix);
   
   cframe = find(frames == frix);   
   
   T = mj_recoverDTfromFeats(DT(cframe));
   
   % Find best Trjs
   [Tord, E, oix] = mj_rankTrjs(T);
   
   n_oix = length(oix);
   if thrmode      
      cframeIx = oix(1:sum(E >= prcj));
   else % percentage
      cframeIx = oix(1:ceil(n_oix*prcj));
   end
   
   ptr = cframe(cframeIx);
   
   % Stats: debug purpose
   lE = [lE, E];
   
   % Stack
   lR = [lR, DT(ptr)];
   lSelIds = [lSelIds, ptr];
end

%% Prepare output
if multiParts
   detectionsSel{1} = lR(ismember(lSelIds, lIds{1}));
   detectionsSel{2} = lR(ismember(lSelIds, lIds{2}));
else
   detectionsSel = lR;   
end % if
clear lR
