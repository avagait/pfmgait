function [model, info, histograms] = mj_trainAndTuneClassifier(histograms, labels, pars, verbose)
% [model, info, histograms] = mj_trainAndTuneClassifier(histograms, labels, pars, verbose)
% Train a classifier
% COMMENT ME!!!
%
% Input:
%  - histograms: training samples in matrix [nsamples, ndims]
%  - labels: column vector with labels
%  - pars: struct
%  - verbose: verbosity level. (0= minimal)
%
% Output:
%  - model: struct
%  - info: struct
%  - histograms: processed samples
%
% See also mj_trainMultiClassCV, mj_PCA
%
% (c) MJMJ/2014


pars = parseParams(pars);

if ~exist('verbose', 'var')
    verbose = 1;
end

%% Gather options
doPCAH = pars.doPCAH;
doML = pars.doML;
cvpars = pars.cvpars;
matml = pars.matml;
mlpars = pars.mlpars;
vC = pars.vC;
kindclassif = pars.kindclassif;
conf = pars.confSVM;
% Parameters for bagging and random subspace.
if isfield(pars, 'TS') && isfield(pars, 'TF')
    conf.TS = pars.TS;
    conf.TF = pars.TF;
end

%% Do the processing
% PCA on histograms?
if doPCAH
    if verbose
        disp('Computing PCA on Histograms');
    end
    pcaobj = mj_PCA(histograms, doPCAH);
    histograms = pcaobj.encode(histograms);
else
    pcaobj = [];
end

% Metric-Learning?
if doML
    %    posIt = mlpars.posIt;
    %
    %    if verbose
    %       disp('Computing dimensionality reduction with Metric Learning');
    %    end
    %
    %    %matml = fullfile(mloutdir, sprintf('%s_K=%04d%s_nFrames=%04d_overlap=%02d.mat', 'ml_model',  K, expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));
    %
    %    if exist(matml, 'file')
    %       fooML = load(matml); modelLM = fooML.model;
    %    else
    %       if strcmp(mlpars.class, 'ClassUnreg')
    %          lm = face_desc.lib.classifier.dimredClassUnreg(doML);
    %       else
    %          lm = face_desc.lib.classifier.dimredJointClassUnreg(doML);
    %       end
    %       lm.set_params(mlpars.params);
    %       lm.numIter = mlpars.numIter; %25*10^4;
    %       lm.logStep = mlpars.logStep; %10^4;
    %       trainData = mj_prepareSetsML(histograms, labels, posIt);
    %
    %       if ~isempty(mlpars.samplesValid)
    %          valData = mj_prepareSetsML(mlpars.samplesValid, mlpars.labelsValid, posIt);
    %       else
    %          valData = mj_prepareSetsML(histograms, labels, posIt);    % Should be a new partition
    %       end
    %
    %       %model = lm.train(trainData, valData, 'modelPath', 'mj_modelJCU.mat');
    %       pcaobj2 = mj_PCA(histograms, doML);
    %       pcaP = pcaobj2.pcaP;
    %       clear pcaobj2
    %       if size(pcaP,2) < doML
    %          difsize = doML - size(pcaP,2);
    %          pcaP = [pcaP, 0.001*randn(size(pcaP,1), difsize)];
    %       end
    %       trainData.dimredModelInit.proj = pcaP'; %pcaobj2.pcaP';
    %       clear pcaP
    %
    %       % Find hard negatives
    %       [pairs, pairDist] = mj_rankSimilarPairs(histograms, labels, doML, true);
    %       PORC = 0.8; % DEVELOP!!!
    %       %[oDist, oix] = sort(pairDist);
    %       trainData.negPairs = [pairs(:,1:ceil(PORC*length(pairDist))), trainData.negPairs];
    %
    %       % Train the distance
    %       modelLM = lm.train(trainData, valData, 'modelPath', matml);
    %       modelLM.obj = lm;
    %
    %       clear trainData valData
    %    end
    %
    %    W = modelLM.state.W;
    %
    %    % Project features
    %    histograms = (W * histograms')';
    [modelLM, histograms] = mj_trainML(histograms, labels, doML, mlpars, matml, verbose);
    
else
    modelLM = [];
end

%% Train
disp('+ Training...');
% cvpars.nfolds = 3;
% cvpars.finalTrain = 0;
% cvpars.verbose = 1;
bestAcc = -inf;
bestC = -inf;
conf.NTrees = pars.K;
switch kindclassif(1:2)
    case {'sv', 'bg'}
        for C = vC,
            conf.svm.C = C;
            [model, accCV] = mj_trainMultiClassCV(histograms, labels, kindclassif, conf, cvpars);
            acc = mean(accCV(isfinite(accCV))); %mean(accCV);
            fprintf('C = %.2f Acc=%.2f\n', C, acc);
            if acc > bestAcc
                bestAcc = acc;
                bestC = C;
            end
        end
    case 'tb'
        [model, accCV] = fc_trainTreeBaggerCV(histograms, labels, conf, cvpars);
        acc = mean(accCV(isfinite(accCV))); %mean(accCV);
        fprintf('\nAcc=%.2f\n', acc);
        
    case 'nb'
        [model, accCV] = fc_trainNaiveBayesCV(histograms, labels, conf, cvpars);
        acc = mean(accCV(isfinite(accCV))); %mean(accCV);
        fprintf('\nAcc=%.2f\n', acc);
    otherwise
        disp('Error, wrong classifier.');
end
% Train the final model with the best C
conf.svm.C = bestC;
switch kindclassif(1:2)
    case {'sv', 'bg'}
        [bestModel, acc, acc_test_pc] = mj_trainMultiClass(histograms, labels, kindclassif, conf);
        % Saving the model.
        bestModel.pcaobj = pcaobj;
        bestModel.lm = modelLM;
    case 'tb'
        [bestModel, acc, acc_test_pc] = fc_trainTreeBagger(histograms, labels, conf);
        % Saving the model.
        bestModel = struct('model', bestModel, 'pcaobj', pcaobj, 'lm', modelLM);
    case 'nb'
        [bestModel, acc, acc_test_pc] = fc_trainNaiveBayes(histograms, labels, conf);
        % Saving the model.
        bestModel = struct('model', bestModel, 'pcaobj', pcaobj, 'lm', modelLM);
    otherwise
        disp('Error, wrong classifier.');
end

%% Output
model = bestModel;
info.acc = acc;
info.acc_pc = acc_test_pc;
info.C = bestC;


%%----------------------------------------
function pars = parseParams(pars)
% Parse parameters
if ~isfield(pars, 'doPCAH')
    pars.doPCAH = 0;
end

if ~isfield(pars, 'K')
    pars.K = 0;
end

if ~isfield(pars, 'doML')
    pars.doML = 0;
end

if ~isfield(pars, 'cvpars')
    cvpars.nfolds = 3;
    cvpars.finalTrain = 0;
    cvpars.verbose = 1;
    pars.cvpars = cvpars;
end

if ~isfield(pars, 'matml')
    pars.matml = sprintf('ml_tmp%05d.mat', round(rand(1)*99999));
end

if ~isfield(pars, 'mlpars')
    mlpars.class = 'ClassUnreg';
    mlpars.params = [0.01, 10];
    mlpars.numIter = 25*10^4;
    mlpars.logStep = 10^4;
    mlpars.posIt = 3;
    pars.mlpars = mlpars;
end

if ~isfield(pars, 'vC')
    pars.vC = [1 10 100];
end

if ~isfield(pars, 'kindclassif')
    pars.kindclassif = 'svmlin';
end


if ~isfield(pars, 'confSVM')
    pars.confSVM.svm.biasMultiplier = 1;
end
