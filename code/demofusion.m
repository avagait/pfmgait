% Demo for gait features fusion
%
% See Castro et al., CAIP'2015
%
% (c) MJMJ/2015

disp('*** This demo shows how to use multimodal features for gait recognition. ***');

%% Get audio scores
demoaudio;
svmscoresAudio = svmscores;

%% Get visual scores
demopfm;
svmscoresVisual = svmscores;

%% Combine scores
% 1) Sum rule:
% ============
svmscoresSum = svmscoresAudio + svmscoresVisual;
[maxScoreSum, idxSum] = max(svmscoresSum);
labelSum = labels_all(idxSum);
fprintf('[Sum-rule] Estimated label for sample is %d with score %.4f ', labelSum, maxScoreSum);
if (labelSum == labels_gt)
   fprintf(' --> Correct!\n');
else
   fprintf(' --> Failure\n');
end

% 2) Weighted scores (WS):
% ========================
fa = 0.15;
fv = 1-fa;
svmscoresSum = fa*svmscoresAudio + fv*svmscoresVisual;
[maxScoreSum, idxSum] = max(svmscoresSum);
labelSum = labels_all(idxSum);
fprintf('[WS] Estimated label for sample is %d with score %.4f ', labelSum, maxScoreSum);
if (labelSum == labels_gt)
   fprintf(' --> Correct!\n');
else
   fprintf(' --> Failure\n');
end
