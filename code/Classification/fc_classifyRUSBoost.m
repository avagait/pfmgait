function [vidEstClass, scores, acc_test, acc_test_pc] = fc_classifyRUSBoost(samples, labels, model)
% [vidEstClass, svmscores, acc_test, acc_test_pc] = mj_classifyMultiClass(samples, labels, model)
% Use the trained classifier to assign a label to the given samples
% COMMENT ME!!!
%
% Input:
%  - samples: test samples in matrix [nsamples, ndims]
%  - labels: column vector with labels [nsamples, 1]. Can be []. Label=0 is
%  ommited during accuracy computation.
%  - model: struct returned by trainMultiClass
%
% Output:
%  - vidEstClass: vector with inferred class labels
%  - scores: matrix [nclasses, nsamples] with classification scores
%  - acc_test: value in [0,1], if labels ~= []
%  - acc_test_pc: vector with accuracy per class. Only trustable if all
%  possible categories are available in 'labels'
%
% See also trainMultiClass, svmpredict
%
% (c) MJMJ/2012
%
% MOD, 13/04/2012, mjmarin: new output 'acc_test_pc'
% MOD, 12/11/2013, mjmarin: this version requires vlfeat 0.9.17 or greater
% MOD, 03/12/2013, mjmarin: new option to normalize data before learning
% MOD, 17/05/2014, mjmarin: trying to handle correctly when no all
% categories are represented in 'labels'. 'acc_test_pc' can report unexepected results.

%if ~isfield(model, 'normalize')
%    model.normalize = false;
%end

%% Preprocess data?
% Normalize data?
%if model.normalize
%    % Mean
%    samples = samples - repmat(model.M, [size(samples,1),1]);
%    % Std
%    samples = samples ./ repmat(model.S+eps, [size(samples,1),1]);
%end

%% Classify samples
% Estimate the class of the samples
[vidEstClass, scores] = predict(model, samples);
nclasses = length(model.ClassNames);

%% Prepare reference labels
 ulabsT = unique(labels(labels > 0));
 if length(ulabsT) < nclasses % There are not test samples from all classes
     ulabsT = [1:size(sample, 1)];
 end
 vidEstClass(labels > 0) = ulabsT(vidEstClass(labels > 0))';

%% Accuracy
if ~isempty(labels)
    acc_test = sum( vidEstClass == labels ) / length(labels);
else
    acc_test = -inf;
end

acc_test_pc = zeros(1,nclasses)-1;
if ~isempty(labels)
    ulabs = unique(labels(labels > 0));
    %nclasses = length(ulabs);
    for i = 1:length(ulabs),
        idx = labels == ulabs(i);
        acc_test_pc(i) = sum( vidEstClass(idx) == labels(idx) ) / length(labels(idx));
    end % i
else
    acc_test_pc = [];
end
