function goodDetections = mj_filterDetsByScore(detections, minScore)
% goodDetections = mj_filterDetsByScore(detections, minScore)
% Input:
%  - detections: matrix [nsamples,6] (last column must be the score)
%  - minScore: detections whose score is lower than 'minScore' are removed
%
% Ouput:
%  - goodDetections: survival detections
%
% (c) MJMJ/2014

if ~isempty(detections)   
   scores = detections(:,end);
   
   goodDetections = detections(scores >= minScore,:);   
else
   goodDetections = [];
end
  