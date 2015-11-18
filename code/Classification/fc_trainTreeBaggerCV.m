function [model, accCV] = fc_trainTreeBaggerCV(samples, labels, conf, cvpars)
% [model, accCV] = fc_trainTreeBaggerCV(samples, labels, conf, cvpars)
% Training a model with n-fold cross-validation 
%
% Input:
%  - samples: training samples in matrix [nsamples, ndims]
%  - labels: column vector with labels [nsamples, 1]. Labels < 1 are
%  considered as fully negative samples and a class will not be trained for
%  them (although are included in others training/testing).
%  - conf: struct with fields
%     .svm.C: e.g. 10
%     .svm.biasMultiplier: e.g. 1
%  - cvpars: parameters for cross-validation. Struct with fields:
%     .nfolds: def. 3
%     .finalTrain: to train a final model with all the samples. Def. false
%     .safeFolds: don't exit if bad number of folds. Def. 1
%     .verbose: def. 0
%
% Output:
%  - model: struct with trained classifiers
%  - accCV: accuracy per fold
%
% See also mj_trainMultiClass, mj_classifyMultiClass
% (c) MJMJ/2013
%
% MOD, mjmarin, Jan/2015: new opt 'safeFolds' for cvpars.

assert(length(labels) == size(samples,1), [mfilename '::number of samples must be equal to number of labels']);

if isempty(cvpars)
   cvpars.nfolds = 3;
   cvpars.safeFolds = 1;
   cvpars.finalTrain = 0;
   cvpars.verbose = 0;
end

if ~isfield(cvpars, 'verbose')
   cvpars.verbose = 0;
end

if ~isfield(cvpars, 'safeFolds')
   cvpars.safeFolds = 1;
end

%% Check inputs
 % Make sure 'labels' is column vector
if numel(labels) > 1 && size(labels,2) > 1
   labels = labels';
end   

%% Useful variables
nsamples = size(samples,1);

%% Prepare folds
[splits, nclasses] = mj_genCrossValSets(labels, cvpars.nfolds, cvpars.safeFolds);

%% Training per fold
accCV = zeros(1,cvpars.nfolds);
bestmodel = [];
bestAcc = -inf;
for fix = 1:cvpars.nfolds
   if cvpars.verbose > 0
      fprintf(' - Fold %02d of %02d ... \r', fix, cvpars.nfolds);
   end
   
   [samplesFTest, labelsFTest, samplesF, labelsF] = mj_getSplitByIdx(samples, labels, splits, fix);
   
   % Training
   [model_, acc_, acc_test_pc_] = fc_trainTreeBagger(samplesF, labelsF, conf);
   
   % Test current model
   [estimClass, svmscores, acc_test, acc_test_pc] = fc_classifyTreeBagger(samplesFTest, labelsFTest, model_);
   accCV(fix) = acc_test;
   
   if acc_test > bestAcc
      bestAcc = acc_test;
      bestmodel = model_;
   end
   
end % fix


%% Final training 
if cvpars.finalTrain
   [model, acc_, acc_test_pc_] = fc_trainTreeBagger(samples, labels, conf);
else
   model = bestmodel;
end
