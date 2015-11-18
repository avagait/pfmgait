function [vidEstClass, svmscores, acc_test, acc_test_pc] = mj_classifyMultiClass(samples, labels, model)
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
%  - svmscores: matrix [nclasses, nsamples] with classification scores per binary classifier
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

kindclassif = model(1).kindclassif;

if ~isfield(model, 'normalize')
    model.normalize = false;
end

%% Preprocess data?
% Normalize data?
if model.normalize
    % Mean
    samples = samples - repmat(model.M, [size(samples,1),1]);
    % Std
    samples = samples ./ repmat(model.S+eps, [size(samples,1),1]);
end

% Compute feature map
switch kindclassif
    case 'svmchi2'
        psix = vl_homkermap(samples', 1, 'kchi2', 'gamma', .5);
    otherwise
        psix = samples';
end

%% Classify samples
nclasses = 0; % Needed for statistics
switch kindclassif
    case {'svmchi2', 'svmlin'}
        
        % Estimate the class of the samples
        svmscores = model.w' * psix + model.b' * ones(1,size(psix,2)) ;
        if isfield(model, 'TS') && isfield(model, 'TF')
            if model.TS <= 1
                TS_ = 1;
            else
                TS_ = model.TS;
            end
            
            if model.TF <= 1
                TF_ = 1;
            else
                TF_ = model.TF;
            end
            vidEstClass = fc_estimateClasses(svmscores, model.TS, model.TF);
            nclasses = size(model.w,2) / (TF_ * TS_);
        else
            [drop, vidEstClass] = max(svmscores, [], 1);
            nclasses = size(model.w,2);
        end
    case {'svmrad', 'svmprob'}                % Radial basis.
        svmmodel = model.w; % Gather actual models
        
        extraopts = '';
        if strcmp(kindclassif, 'svmprob')
            extraopts = ' -b 1';
        end
        
        svmscores = [];
        nclasses = length(svmmodel);
        for ci = 1:nclasses,
            if ~isempty(labels)
                y = 2 * (labels == ci) - 1 ;
            else
                y = ones(size(psix, 2),1);
            end
            %svmmodel(ci) = svmtrain(double(y(idxtrain)), double(psix(:,idxtrain)'), ['-t 2 ' sprintf(' -c %f -g %f', conf.svm.C, gammasvm)]);
            
            [predict_label, accuracy, scores] = svmpredict(double(y), double(psix'), svmmodel(ci), extraopts);
            if strcmp(kindclassif, 'svmprob')
                if svmmodel(ci).Label(1) < 0
                    svmscores(ci,:) = scores(:,2)';
                else
                    svmscores(ci,:) = scores(:,1)';
                end
            else
                svmscores(ci,:) = scores .* svmmodel(ci).Label(1); % Assign right sign
            end
        end
        
        % Estimate the class of the samples
        [drop, vidEstClass] = max(svmscores, [], 1);
        
    case 'gb'
        nclasses = length(model);
        F = [];
        for cix = 1:nclasses,
            [Cx, Fx] = strongGentleClassifier(psix, model(cix).classifier);
            F = [F; Fx];
        end
        svmscores = F;
        
        [mxv, vidEstClass] = max(F, [], 1);
    
    case 'svmradnat'
        svmmodel = model.modelrad; % Gather actual models
        svmscores = [];
        nclasses = length(svmmodel);
        for ci = 1:nclasses,            
            predict_label = svmclassify(svmmodel(ci), double(psix'));
            Sample = double(psix');
            SampleScaleShift = bsxfun(@plus, Sample, svmmodel(ci).ScaleData.shift);
            Sample = bsxfun(@times, SampleScaleShift, svmmodel(ci).ScaleData.scaleFactor);
            sv = svmmodel(ci).SupportVectors;
            alphaHat = svmmodel(ci).Alpha;
            bias = svmmodel(ci).Bias;
            kfun = svmmodel(ci).KernelFunction;
            kfunargs = svmmodel(ci).KernelFunctionArgs;
            f = kfun(sv, Sample, kfunargs{:})'*alphaHat(:) + bias;
            svmscores(ci, :) = f'*-1;
        end
        
        % Estimate the class of the samples
        [drop, vidEstClass] = max(svmscores, [], 1);
    otherwise
        error([' Invalid type: ' kindclassif])
end

%% Prepare reference labels
ulabsT = unique(labels(labels > 0));
if length(ulabsT) < nclasses % There are not test samples from all classes
    ulabsT = [1:nclasses];
end
vidEstClass(labels > 0) = ulabsT(vidEstClass(labels > 0))';

%% Accuracy
if ~isempty(labels)
    acc_test = sum( vidEstClass' == labels ) / length(labels);
else
    acc_test = -inf;
end

acc_test_pc = zeros(1,nclasses)-1;
if ~isempty(labels)
    ulabs = unique(labels(labels > 0));
    %nclasses = length(ulabs);
    for i = 1:length(ulabs),
        idx = labels == ulabs(i);
        acc_test_pc(i) = sum( vidEstClass(idx)' == labels(idx) ) / length(labels(idx));
    end % i
else
    acc_test_pc = [];
end
