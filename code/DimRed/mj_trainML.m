function [modelLM, histograms] = mj_trainML(histograms, labels, newdims, mlpars, matml, verbose)
% mj_trainML
% Metric Learning training
% Input:
% Output:
%
% (c) MJMJ/2015

if ~exist('verbose', 'var')
   verbose = 1;
end

posIt = mlpars.posIt;

if isfield(mlpars, 'trainData')
   trainData = mlpars.trainData;
   nPos = size(trainData.posPairs,2);
   if nPos == 0
      error('Invalid number of positive pairs for training!')
   end
   if verbose
      fprintf('\nUsing %d custom pairs for training\n', nPos);
   end
else
   trainData = [];
end

if isfield(mlpars, 'valData')
   valData = mlpars.valData;
   nPos = size(valData.posPairs,2);
   if nPos == 0
      error('Invalid number of positive pairs for validation!')
   end   
   if verbose
      fprintf('\nUsing %d custom pairs for validation\n', nPos);
   end   
else
   valData = [];
end

if verbose
   disp(['Computing dimensionality reduction with Metric Learning ' mlpars.class]);
end

%matml = fullfile(mloutdir, sprintf('%s_K=%04d%s_nFrames=%04d_overlap=%02d.mat', 'ml_model',  K, expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));

if exist(matml, 'file') && mlpars.whiteData == -1
   fooML = load(matml); modelLM = fooML.model;
else
   if strcmp(mlpars.class, 'ClassUnreg')
      lm = face_desc.lib.classifier.dimredClassUnreg(newdims);
   elseif strcmp(mlpars.class, 'JointClassUnreg')
      lm = face_desc.lib.classifier.dimredJointClassUnreg(newdims);
   else
      lm = face_desc.lib.classifier.diagMetricRank();
   end
   lm.set_params(mlpars.params);
   lm.numIter = mlpars.numIter; %25*10^4;
   if ~isempty(strfind(mlpars.class, 'Class'))
      lm.logStep = mlpars.logStep; %10^4;
   end
   
   % Prepare data
   if isempty(trainData)
      trainData = mj_prepareSetsML(histograms, labels, posIt);
   end
   
   if isempty(valData)
      if ~isempty(mlpars.samplesValid)
         valData = mj_prepareSetsML(mlpars.samplesValid, mlpars.labelsValid, posIt);
      else
         valData = mj_prepareSetsML(histograms, labels, posIt);    % Should be a new partition
      end
   end
      
   % Initialize with PCA
   pcaobj2 = mj_PCA(histograms, newdims);
   pcaP = pcaobj2.pcaP; pcaM = pcaobj2.pcaM;
   clear pcaobj2
   if size(pcaP,2) < newdims
      difsize = newdims - size(pcaP,2);
      pcaP = [pcaP, 0.001*randn(size(pcaP,1), difsize)];
   end
   trainData.dimredModelInit.proj = pcaP'; %pcaobj2.pcaP';
   clear pcaP
   
   % Find hard negatives
   [pairs, pairDist] = mj_rankSimilarPairs(histograms, labels, newdims, true);
   PORC = 0.8; % DEVELOP!!!
   %[oDist, oix] = sort(pairDist);
   trainData.negPairs = [pairs(:,1:ceil(PORC*length(pairDist))), trainData.negPairs];
   
   % Do whitening?
   if mlpars.whiteData > 0
      disp('Data whitening...');
      [data, wM, wP] = mj_zcaWhite(trainData.feats', 1e-05);
      trainData.feats = data'; clear data
      
      [data, wM, wP] = mj_zcaWhite(valData.feats', 1e-05);
      valData.feats = data'; clear data      
   else
      wP = 1.0;
      
      if mlpars.whiteData == 0 % Minus mean
         wM = pcaM;
         [data, wM_, wP_] = mj_zcaWhite(trainData.feats', 1e-05, wM, wP);
         trainData.feats = data'; clear data
         
         [data, wM_, wP_] = mj_zcaWhite(valData.feats', 1e-05, wM, wP);
         valData.feats = data'; clear data
      else
         wM = 0;
      end
   end
   
   % Train the distance
   modelLM = lm.train(trainData, valData, 'modelPath', matml);
   modelLM.obj = lm;
   modelLM.wM = wM;
   modelLM.wP = wP;
   
   clear trainData valData
end

W = modelLM.state.W;

% Project features
histograms = (W * histograms')';
   