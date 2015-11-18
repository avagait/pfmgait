function [model, acc, acc_test_pc] = fc_trainTreeBagger(samples, labels, conf)
% [model, acc, acc_test_pc] = fc_trainTreeBagger(samples, labels, conf)
% Train a tree bagger given the samples
% COMMENT ME!!!
%
% Input:
%  - samples: training samples in matrix [nsamples, ndims]
%  - labels: column vector with labels [nsamples, 1]. Labels < 1 are
%  considered as fully negative samples and a class will not be trained for
%  them (although are included in others training/testing).
%  - conf: struct with fields
%     .NTress: number of trees.
%     .normalize: def. false
%
% Output:
%  - model: struct with trained classifiers
%  - acc: accuracy
%  - acc_test_pc: accuracy per class
%
% Dependencies: vl_feat, libsvm
%
% See also mj_classifyMultiClass, vl_homkermap, vl_svmtrain, svmtrain
%
% (c) MJMJ/2012
%

if ~isfield(conf, 'normalize')
    conf.normalize = false;
end

%% Define useful vars
valix = labels > 0;
ulabs = unique(labels(valix));
nclasses = length(ulabs);

if nclasses < 1
    warning('All training samples belong to an invalid class!');
end

%% Preprocess data?
% Normalize data?
model.normalize = conf.normalize;
if conf.normalize
    % Mean
    M = mean(samples);
    samples = samples - repmat(M, [size(samples,1),1]);
    % Std
    S = std(samples);
    samples = samples ./ repmat(S+eps, [size(samples,1),1]);
    model.M = M;
    model.S = S;
end

%% Train classifier
% Train classifier
%model = fitcnb(samples, labels);
model = fitcnb(samples, labels, 'Distribution', 'kernel');
% Estimate the class of the samples
vidEstClass = predict(model, samples);

%% Statistics
% vidEstClass = ulabs(vidEstClass(valix)); % Covert to reference labels
%acc = sum( vidEstClass(valix) == labels(valix) ) / length(labels(valix)); % BUG!!!
acc = sum( vidEstClass == labels(valix) ) / length(labels(valix));

if ~isempty(labels)
    ulabs = unique(labels(labels > 0));
    nclasses = length(ulabs);
    labelsGT = labels(valix); % Discard full-negative samples
    for i = 1:nclasses,
        idx = labelsGT == ulabs(i);
        acc_test_pc(i) = sum( vidEstClass(idx) == labelsGT(idx) ) / length(labelsGT(idx));
    end % i
else
    acc_test_pc = [];
end
