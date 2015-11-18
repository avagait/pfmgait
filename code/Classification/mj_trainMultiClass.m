function [model, acc, acc_test_pc] = mj_trainMultiClass(samples, labels, kindclassif, conf)
% [model, acc, acc_test_pc] = mj_trainMultiClass(samples, labels, kindclassif, conf)
% Train a multiclass classifier given the samples
% COMMENT ME!!!
%
% Input:
%  - samples: training samples in matrix [nsamples, ndims]
%  - labels: column vector with labels [nsamples, 1]. Labels < 1 are
%  considered as fully negative samples and a class will not be trained for
%  them (although are included in others training/testing).
%  - kindclassif: string. Can be {'svmchi2', 'svmlin', 'svmrad', 'svmprob'}
%  - conf: struct with fields
%     .svm.C: e.g. 10
%     .svm.biasMultiplier: e.g. 1
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
% MOD, 13/04/2012, mjmarin: labels < 1 means, fully negative sample
% MOD, 02/06/2012, mjmarin: svmprob is supported
% MOD, 27/06/2012, mjmarin: accuracy per class is returned
% MOD, 12/11/2013, mjmarin: this version requires vlfeat 0.9.17 or greater
% MOD, 03/12/2013, mjmarin: new option to normalize data before learning
% MOD, 18/05/2014, mjmarin: bug fix at computing accuracy

%bestAcc = -inf;  % Best accuracy based on C

% Check version
if strcmp(kindclassif, 'svmchi2') || strcmp(kindclassif, 'svmlin')
    vv = regexp(vl_version, '\d+', 'Match');
    if str2double(vv{2}) >= 9 && str2double(vv{3}) >= 17
        validVL = true;
    else
        validVL = false;
    end
end

if ~isfield(conf, 'normalize')
    conf.normalize = false;
end

%% Define useful vars
model.kindclassif = kindclassif;

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

% Compute feature map
switch kindclassif
    case 'svmchi2'
        psix = vl_homkermap(samples', 1, 'kchi2', 'gamma', .5);
    otherwise
        psix = samples';
end

%% Train classifiers
switch kindclassif
    case {'svmchi2', 'svmlin'}
        solver = 'sdca';
        %conf.svm.C = vC(ii);          %10;
        %conf.svm.biasMultiplier = 1;
        C = conf.svm.C;
        biasM = conf.svm.biasMultiplier;
        w = [];
        %         if validVL
        b = [];
        if isfield(conf, 'TS') && isfield(conf, 'TF')
            %index = 1;
            TS = conf.TS;
            TF = conf.TF;
            
            for ci = 1:nclasses,
                wi = [];
                bi = [];
                if TS > 1 % Do bagging?
                    for tsi = 1:TS
                        [subsample, sublabels] = fc_computeBagging(psix, labels, ci);
                        if TF > 1 % Do random subspace?
                            for tfi = 1:TF
                                finalSample = fc_computeRandomSubspace(subsample);
                                [wb, bb, infotrain] = mj_trainSVM(C, biasM, finalSample, sublabels, ulabs, ci, solver, validVL);
                                wi = [wi, wb];
                                bi = [bi, bb];
                            end
                        else
                            [wb, bb, infotrain] = mj_trainSVM(C, biasM, subsample, sublabels, ulabs, ci, solver, validVL);
                            wi = [wi, wb];
                            bi = [bi, bb];
                        end
                    end
                elseif TF > 1 % Do random subspace?
                    for tfi = 1:TF
                        finalSample = fc_computeRandomSubspace(psix);
                        [wb, bb, infotrain] = mj_trainSVM(C, biasM, finalSample, labels, ulabs, ci, solver, validVL);
                        wi = [wi, wb];
                        bi = [bi, bb];
                    end
                end
                
                w{ci} = wi;
                b{ci} = bi;
            end
            
            w = cell2mat(w);
            b = cell2mat(b);
            %                 parfor ci = 1:nclasses,
            %                     if TS > 1 % Do bagging?
            %                         for tsi = 1:TS
            %                             [subsample, sublabels] = fc_computeBagging(psix, labels, ci);
            %                             if TF > 1 % Do random subspace?
            %                                 for tfi = 1:TF
            %                                     finalSample = fc_computeRandomSubspace(subsample);
            %                                     [w(:,index), b(index), infotrain] = mj_trainSVM(C, biasM, finalSample, sublabels, ulabs, ci, solver, validVL);
            %                                     index = index + 1;
            %                                 end
            %                             else
            %                                 [w(:,index), b(index), infotrain] = mj_trainSVM(C, biasM, subsample, sublabels, ulabs, ci, solver, validVL);
            %                                 index = index + 1;
            %                             end
            %                         end
            %                     elseif TF > 1 % Do random subspace?
            %                         for tfi = 1:TF
            %                             finalSample = fc_computeRandomSubspace(psix);
            %                             [w(:,index), b(index), infotrain] = mj_trainSVM(C, biasM, finalSample, labels, ulabs, ci, solver, validVL);
            %                             index = index + 1;
            %                         end
            %                     end
            %                 end
            
            
            %                     for tsi = 1:conf.TS
            % %                         sp = sum(labels == ulabs(ci)); % Split point.
            % %                         % Negative samples.
            % %                         negative = psix(:, labels ~= ulabs(ci));
            % %                         negativeLabels = labels(labels ~= ulabs(ci));
            % %                         % Add positive samples.
            % %                         subsample = zeros(size(psix, 1), 2*sum(labels == ulabs(ci)));
            % %                         subsample(:, 1:sp) = psix(:, labels == ulabs(ci));
            % %                         % Add negative samples.
            % %                         p = randperm(size(negative, 2));
            % %                         subsample(:, sp+1:end) = negative(:, p(1:sp));
            % %                         sublabels = labels(labels == ulabs(ci));
            % %                         sublabels = [sublabels ; negativeLabels(p(1:sp))];
            %                         for tfi = 1:conf.TF
            % %                             finalSample = zeros(size(subsample));
            % %                             p = randperm(size(subsample, 1));
            % %                             lim = round(sqrt(size(subsample, 1)));
            % %                             finalSample(p(1:lim), :) = subsample(p(1:lim), :);
            %                             lambda = 1 / (C *  size(finalSample,2));
            %                             y = 2 * (sublabels == ulabs(ci)) - 1 ;
            %                             % Train classifier
            %                             [w(:,index), b(index), infotrain] = vl_svmtrain(finalSample, y, lambda, ...
            %                                 'Solver', solver, 'MaxNumIterations', 50/lambda, ...
            %                                 'BiasMultiplier', biasM, 'Epsilon', 1e-3);
            %                             index = index + 1;
            %                         end
            %                     end
            %                end % ci
            if validVL
                model.b = biasM * b;
                model.w = w;
            else
                model.b = biasM * w(end, :);
                model.w = w(1:end-1, :);
            end
            
            model.C = C;
            model.TF = conf.TF;
            model.TS = conf.TS;
        else
            parfor ci = 1:nclasses,
                %                     lambda = 1 / (C *  size(psix,2));
                %                     y = 2 * (labels == ulabs(ci)) - 1 ;
                % Train classifier
                [w(:,ci), b(ci), infotrain] = mj_trainSVM(C, biasM, psix, labels, ulabs, ci, solver, validVL);
                %                     [w(:,ci), b(ci), infotrain] = vl_svmtrain(psix, y, lambda, ...
                %                         'Solver', solver, 'MaxNumIterations', 50/lambda, ...
                %                         'BiasMultiplier', biasM, 'Epsilon', 1e-3);
                
            end % ci
            if validVL
                model.b = biasM * b;
                model.w = w;
            else
                model.b = biasM * w(end, :);
                model.w = w(1:end-1, :);
            end
            
            model.C = C;
        end
        %         else
        %             if isfield(conf, 'TS') && isfield(conf, 'TF')
        %                 index = 1;
        %                 for ci = 1:nclasses,
        %                     for tsi = 1:conf.TS
        %                         sp = sum(labels == ulabs(ci));
        %                         negative = psix(:, labels ~= ulabs(ci));
        %                         negativeLabels = labels(labels ~= ulabs(ci));
        %                         subsample = zeros(size(psix, 1), 2*sum(labels == ulabs(ci)));
        %                         subsample(:, 1:sp) = psix(:, labels == ulabs(ci));
        %                         p = randperm(size(negative, 2));
        %                         subsample(:, sp+1:end) = negative(:, p(1:sp));
        %                         sublabels = labels(labels == ulabs(ci));
        %                         sublabels = [sublabels ; negativeLabels(p)];
        %                         for tfi = 1:conf.TF
        %                             finalSample = zeros(size(subsample));
        %                             p = randperm(size(subsample, 1));
        %                             lim = round(sqrt(size(subsample, 1)));
        %                             finalSample(p(1:lim), :) = subsample(p(1:lim), :);
        %
        %                             lambda = 1 / (C *  size(finalSample,2));
        %                             y = 2 * (sublabels == ulabs(ci)) - 1 ;
        %                             % Train classifier
        %                             w(:,ci) = vl_pegasos(psix, int8(y), lambda, 'NumIterations', 50/lambda, 'BiasMultiplier', biasM);
        %                             index = index + 1;
        %                         end
        %                     end
        %                 end % ci
        %                 model.b = biasM * w(end, :);
        %                 model.w = w(1:end-1, :);
        %                 model.C = C;
        %                 model.TF = conf.TF;
        %                 model.TS = conf.TS;
        %             else
        %                 parfor ci = 1:nclasses,
        %                     lambda = 1 / (C *  size(psix,2));
        %                     y = 2 * (labels == ulabs(ci)) - 1 ;
        %                     % Train classifier
        %
        %                     w(:,ci) = vl_pegasos(psix, int8(y), lambda, 'NumIterations', 50/lambda, 'BiasMultiplier', biasM) ;
        %
        %                 end % ci
        %
        %                 model.b = biasM * w(end, :) ;
        %                 model.w = w(1:end-1, :) ;
        %                 model.C = C;
        %             end
        %         end
        
        
        % Estimate the class of the samples
        svmscores = model.w' * psix + model.b' * ones(1,size(psix,2)) ;
        if isfield(model, 'TS') && isfield(model, 'TF')
            vidEstClass = fc_estimateClasses(svmscores, conf.TS, conf.TF);
        else
            [drop, vidEstClass] = max(svmscores, [], 1);
        end
    case {'svmrad', 'svmprob'}                % Radial basis. TODO: cross-validate parameter 'gamma'
        %conf.svm.C = vC(ii);          %10;
        %conf.svm.biasMultiplier = 1;
        
        extraopts = '';
        if strcmp(kindclassif, 'svmprob')
            extraopts = ' -b 1';
        end
        
        best_acc_test_gamma = -inf;
        best_gamma = 1;
        vgamma = [0.5, 1, 1.5, 2];  % DEVELOP!!!
        for gix = 1:length(vgamma),
            gammasvm = vgamma(gix)/size(psix, 2);
            svmscores = [];
            for ci = 1:nclasses,
                y = 2 * (labels == ulabs(ci)) - 1 ;
                svmmodel(ci) = svmtrain(double(y), double(psix'), ['-t 2 ' sprintf(' -c %f -g %f', conf.svm.C, gammasvm) extraopts]);
                
                % Test
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
            model.w = svmmodel;
            model.C = conf.svm.C;
            [drop, vidEstClass] = max(svmscores, [], 1);
            
            % Test value
            acc_test_gamma = sum( vidEstClass' == labels ) / length(labels);
            if acc_test_gamma > best_acc_test_gamma
                best_acc_test_gamma = acc_test_gamma;
                best_gamma = gammasvm;
                best_model = model;
            end
        end % vgamma
        fprintf('\t Best acc: %.2f (gamma=%f)', 100*best_acc_test_gamma, best_gamma);
        model = best_model;
        
    case 'svmradnat'                % Radial basis. TODO: cross-validate parameter 'gamma'  
        best_acc_test_gamma = -inf;
        best_gamma = 1;
        vgamma = [0.5, 1, 1.5, 2];  % DEVELOP!!!
        for gix = 1:length(vgamma),
            gammasvm = vgamma(gix)/size(psix, 2);
            svmscores = [];
            for ci = 1:nclasses,
                y = 2 * (labels == ulabs(ci)) - 1 ;
                svmmodel(ci) = svmtrain(double(psix'), double(y), 'kernel_function', 'rbf', 'boxconstraint', conf.svm.C, 'rbf_sigma', gammasvm);
                
                % Test
                results = svmclassify(svmmodel(ci), double(psix'));
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
            model.w = svmscores;
            model.C = conf.svm.C;
            model.modelrad = svmmodel;
            [drop, vidEstClass] = max(svmscores, [], 1);
            
            % Test value
            acc_test_gamma = sum( vidEstClass' == labels ) / length(labels);
            if acc_test_gamma > best_acc_test_gamma
                best_acc_test_gamma = acc_test_gamma;
                best_gamma = gammasvm;
                best_model = model;
            end
        end % vgamma
        fprintf('\t Best acc: %.2f (gamma=%f)', 100*best_acc_test_gamma, best_gamma);
        model = best_model;
    case 'gb'
        Nrounds = size(samples,2);
        labels = labels(:)';
        [model, acc_test] = gentleBoostOneVsAll(psix, labels, Nrounds, psix, labels);
        vidEstClass = acc_test.C';
        model(1).kindclassif = kindclassif;
        
    otherwise
        error(['Unknown classifier: ' kindclassif]);
end % switch

%% Statistics
vidEstClass = ulabs(vidEstClass(valix)); % Covert to reference labels
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
end

function [w, b, infotrain] = mj_trainSVM(C, biasM, finalSample, labels, ulabs, ci, solver, validVL)
lambda = 1 / (C *  size(finalSample,2));
y = 2 * (labels == ulabs(ci)) - 1 ;
% Train classifier
if validVL
    [w, b, infotrain] = vl_svmtrain(finalSample, y, lambda, ...
        'Solver', solver, 'MaxNumIterations', 50/lambda, ...
        'BiasMultiplier', biasM, 'Epsilon', 1e-3);
else
    w = vl_pegasos(finalSample, int8(y), lambda, 'NumIterations', 50/lambda, 'BiasMultiplier', biasM);
end
end
