% File: mj_trainGaitGen.m
%
% Learn a model to classify people using motion flows.
% First version by FMCP
% MOD, mjmarin, Nov/2013: this version uses Fisher Vectors

verbose = 1;

%avaSubjects;

% -------------------- Parameters -------------------- %
% if isunix
%    if useOldDirs
%       %experdir = '/data/mjetal/';
%       experdir = '/data/experiments/casiaB/silhouettes/';
%    else
%       %experdir = '/home/cifs/mjetal/experiments/gait/';
% 	experdir = '/data/mjetal/experiments/casiaB/silhouettes/';
% 	%experdir = '/data/mjetal/experiments/casiaC/';
%    end
% else
%    if ~isUCOpc
%       experdir = 'D:\experiments\gait\';
%    else
%       experdir = 'F:\experiments\gait\';
%    end
% end

%% Define directories
mj_gaitLocalPaths;

if ~exist('kinddic', 'var')
    kinddic = 'fv';
end

if ~exist('rootdirfix', 'var')
    rootdirfix = '';
end

switch kinddic
    case 'fv'
        outdirbase = fullfile(experdir, ['fv' rootdirfix]);
    case 'bow'
        outdirbase = fullfile(experdir, ['bow' rootdirfix]);
    otherwise
        error('Invalid kinddic');
end
featuresPath = fullfile(experdir, 'tracked_dense_feats80x60'); % Path of the samples.
tracksPath = fullfile(experdir, 'tracks80x60'); % Path of the tracks.
outputName = 'full_model';  % Name of the model file saved.
dictionaryName = 'full_dictionary'; % Name of the dictionary file.
matmlName = 'ml_model';
conf.svm.biasMultiplier = 1;    % Configuration of the SVM.
vC = [0.1,1,10,50,100]; % Possible C values for SVM
% -------------------- Parameters -------------------- %

if ~exist('kindclassif', 'var')
    kindclassif = 'svmlin';      % svmlin is good for FV, but svmchi2 is more suitable for BOW
end

if ~exist('doPCA','var')
    doPCA = 0;
end

if ~exist('doPCAH','var')
    doPCAH = 0;
end

if ~exist('doML','var')
    doML = 0;
end

if ~exist('doDTsel', 'var')
    doDTsel = 0;
end

% Check if createDictionary exists.
if ~exist('createDictionary', 'var')
    createDictionary = 0;
end

if ~exist('skipIfDone', 'var')
    skipIfDone = false;
end

if ~exist('vK', 'var')
    vK = [50];
end

% Check if cams exists.
if ~exist('cams', 'var')
    cams = 90;
end

% Check if trajectories exists.
if ~exist('trajectories', 'var')
    trajectories = 'nm';
end

% Check if sequences exists.
if ~exist('sequences', 'var')
    sequences = [1 2 3 4];
end

if ~exist('ftdims', 'var')
    ftdims = [30 96 96 96];
end

if ~exist('sqrtsel', 'var')
    sqrtsel = [0 1 1 1];
end

if ~exist('kinddata', 'var')
    kinddata = 'video';
    doNormAudio = 0;
end

if ~exist('doNormAudio', 'var')
    doNormAudio = 0;
end

if ~exist('mlmodel', 'var')
   mlmodel = 'ClassUnreg'; % Opts: {'ClassUnreg', 'JointClassUnreg'}
end

if ~exist('earlyFusion', 'var')
    earlyFusion = 0;
end

if ~exist('outOfSample', 'var')
   outOfSample = 0;
end

if ~exist('doNewSamples', 'var')
    doNewSamples = 0;
end

if ~exist('doNewSamplesBand', 'var')
    doNewSamplesBand = 0;
end

% Check available partitions
mj_defaultPartitionsTrainGait;

% Prepare experiment name
if ~isempty(cams)
    cams = sort(cams);
    cams_str = sprintf('%03d', cams(1));
    for i=2:length(cams)
        cams_str = [cams_str, '_', sprintf('%03d', cams(i))];
    end
else
    cams_str = '';
end

sequences = sort(sequences);
sequences_str = sprintf('%02d', sequences(1));
for i=2:length(sequences)
    sequences_str = [sequences_str, '_', sprintf('%02d', sequences(i))];
end

trajectories_str = trajectories;

fprintf('Trajectory = %s, Sequence = %s, Camera = %s \n', trajectories_str, sequences_str, cams_str);

extrafix = '';
if doDTsel > 0
   extrafix = [extrafix sprintf('_DTs%02d', round(doDTsel(1)*100))];
elseif doDTsel < 0
   extrafix = [extrafix sprintf('_DTsX%02d', round(abs(doDTsel(1))*10))];   
end

if doPCA > 0
    extrafix = [extrafix sprintf('_PCA%03d', doPCA(1))];
end

doSqrt = ~isempty(sqrtsel)  && any(sqrtsel);
if doSqrt
    extrafix = [extrafix, '_sq'];
end
[extrafixdir, extrafixexper] = mj_buildPartsString(partitions_train);
% if length(partitions_train(1).partition) == 1
%    extrafix = [extrafix sprintf('_part%02d', partitions_train(1).partition)];
% end
extrafix = [extrafix, extrafixdir];

if earlyFusion
    extrafix = [extrafix, '_fusion'];
end

outdir = fullfile(outdirbase, sprintf('trj%sseq%scam%s%s', trajectories_str, sequences_str, cams_str, extrafix));
if ~exist(outdir,'dir')
    mkdir(outdir);
end

svmOutputdir = fullfile(outdir, 'models'); % Directory to save the model.
if ~exist(svmOutputdir,'dir')
    mkdir(svmOutputdir);
end

dictionariesOutputdir = fullfile(outdir, 'dictionaries'); % Directory to save dictionaries.
if ~exist(dictionariesOutputdir,'dir')
    mkdir(dictionariesOutputdir);
end

samplesOutputdir = fullfile(outdir, 'samples'); % Directory to save the samples
if ~exist(samplesOutputdir,'dir')
    mkdir(samplesOutputdir);
end

dicpars.doPCA = doPCA;
dicpars.vdims = ftdims; % Def. [30 96 96 96] for DCS
dicpars.sqrt = sqrtsel;
dicpars.dbname = dbname;
dicpars.doDTsel = doDTsel;
dicpars.subjects = [subjectsTrn; subjectsVal];
dicpars.kinddata = kinddata;
dicpars.doNormAudio = doNormAudio;

encpars.ftdims = dicpars.vdims;
encpars.ftsel = [1 1 1 1]; %[0 1 1 1];   % Def. [1 1 1 1]
encpars.sqrt = sqrtsel;
encpars.dbname = dbname;
encpars.doDTsel = doDTsel;
encpars.subjects = subjectsTst;
encpars.kinddata = kinddata;
encpars.doNormAudio = doNormAudio;
encpars.newSamples = doNewSamples;
encpars.newSamplesBand = doNewSamplesBand;

if doNewSamples > 0
     encpars.percent = newSamplesPercent;
end

if exist('otherLabels', 'var')
    encpars.subjects = dicpars.subjects;
    encpars.labels = otherLabels;
end

if strcmp(kindclassif, 'svmlin')
    conf.normalize = 1; % Normalize data during training/testing
end

expernamefix = '';
% if isfield(partitions_train, 'join') && any([partitions_train.join] > 0)
%    expernamefix = [expernamefix '_jn'];
% end
expernamefix = [expernamefix, extrafixexper];

if doPCAH > 0
    expernamefix = [expernamefix sprintf('_PCAH%03d', doPCAH)];
end
if doML > 0
    expernamefix = [expernamefix sprintf('_ML%03d', doML)];
end

if strcmp('audio', kinddata)
    outputName = strcat(outputName, '_audio');
    dictionaryName = strcat(dictionaryName, '_audio');
    matmlName = strcat(matmlName, '_audio');
    featuresPath = fullfile(experdir, 'audio_feats', 'ft0111'); % Path of the samples.
end

if earlyFusion
    switch kindFusion
    case 1
	outputName = strcat(outputName, '_earlyFusionConcat');
    	matmlName = strcat(matmlName, '_earlyFusionConcat');
    case 2
	outputName = strcat(outputName, '_earlyFusionBiModal');
    	matmlName = strcat(matmlName, '_earlyFusionBiModal');
    case 3
	outputName = strcat(outputName, '_earlyFusionR');
    	matmlName = strcat(matmlName, '_earlyFusionR');
    end	
    %outputName = strcat(outputName, '_earlyFusion');
    %matmlName = strcat(matmlName, '_earlyFusion');
    featuresPathAudio = fullfile(experdir, 'audio_feats', 'ft0111'); % Path of the samples.
    featuresPathRGB = featuresPath;
    tracksPathRGB = tracksPath;
    featuresPathDepth = fullfile(experdir, 'depth_tracked_dense_feats'); % Path of the samples.tracked_dense_feats2
    tracksPathDepth = fullfile(experdir, 'depth_tracks'); % Path of the tracks. tracks2
    tracksPathAudio = '';
end

if ~outOfSample
    % Loop over dictionary size
    for i = 1:length(vK)
        K = vK(i);
        if earlyFusion
            if isequal(sources, [1 1 0])
                matmodel = fullfile(svmOutputdir,...
            sprintf('%s_%s_dcs_hox_K=%04d_K=%04d%s_nFrames=%04d_overlap=%02d.mat', outputName, kindclassif, K, vKDepth(i), expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));
            elseif isequal(sources, [1 0 1])
                matmodel = fullfile(svmOutputdir,...
            sprintf('%s_%s_dcs_audio_K=%04d_K=%04d%s_nFrames=%04d_overlap=%02d.mat', outputName, kindclassif, K, vKAudio(i), expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));
            elseif isequal(sources, [0 1 1])
                matmodel = fullfile(svmOutputdir,...
            sprintf('%s_%s_hox_audio_K=%04d_K=%04d%s_nFrames=%04d_overlap=%02d.mat', outputName, kindclassif, vKDepth(i), vKAudio(i), expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));
            elseif isequal(sources, [1 1 1])
                matmodel = fullfile(svmOutputdir,...
            sprintf('%s_%s_dcs_hox_audio_K=%04d_K=%04d_K=%04d%s_nFrames=%04d_overlap=%02d.mat', outputName, kindclassif, K, vKDepth(i), vKAudio(i), expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));
            end
        else
        matmodel = fullfile(svmOutputdir,...
            sprintf('%s_%s_K=%04d%s_nFrames=%04d_overlap=%02d.mat', outputName, kindclassif, K, expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));
        end

        if exist(matmodel, 'file') && skipIfDone
            disp('+ Model already exists. Skipping...');
            continue
        end

        if earlyFusion
            % RGB
            if sources(1)
                kinddata = 'video';
                matdic = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryName, vK(i)));
                if createDictionary && (~skipIfDone || (skipIfDone && ~exist(matdic, 'file')))
                    disp('+ Computing dictionary...');
                    dicpars.doPCA = doPCARGB;
                    dictionary = mj_createDictionaryGen(featuresPathRGB, partitions_dicRGB, vK(i), cams, trajectories, sequences, kinddic, dicpars);
                    %matdets = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryName, vK(i)));
                    save(matdic, 'dictionary');
                    dictionaryRGB = dictionary;
                else
                    disp('+ Loading dictionary...');
                    dictionaryRGB = load(matdic);
                    dictionaryRGB = dictionaryRGB.dictionary;
                end
            else
                dictionaryRGB = [];
            end

            % Depth
            if sources(2)
                dictionaryNameDepth = strcat(dictionaryName, '_hox');
                matdic = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryNameDepth, vKDepth(i)));
                if createDictionary && (~skipIfDone || (skipIfDone && ~exist(matdic, 'file')))
                    disp('+ Computing dictionary...');
                    dicpars.doPCA = doPCADepth;
                    dictionary = mj_createDictionaryGen(featuresPathDepth, partitions_dicDepth, vKDepth(i), cams, trajectories, sequences, kinddic, dicpars);
                    %matdets = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryName, vK(i)));
                    save(matdic, 'dictionary');
                    dictionaryDepth = dictionary;
                else
                    disp('+ Loading dictionary...');
                    dictionaryDepth = load(matdic);
                    dictionaryDepth = dictionaryDepth.dictionary;
                end
            else
                dictionaryDepth = [];
            end

            % Audio
            if sources(3)
                kinddata = 'audio';
                dictionaryNameAudio = strcat(dictionaryName, '_audio');
                matdic = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryNameAudio, vKAudio(i)));
                if createDictionary && (~skipIfDone || (skipIfDone && ~exist(matdic, 'file')))
                    disp('+ Computing dictionary...');
                    dicpars.doPCA = doPCAAudio;
                    dicpars.dbname = 'tum_gaid_audio';
                    dicpars.kinddata = 'audio';
                    dictionary = mj_createDictionaryGen(featuresPathAudio, partitions_dicAudio, vKAudio(i), cams, trajectories, sequences, kinddic, dicpars);
                    %matdets = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryName, vK(i)));
                    save(matdic, 'dictionary');
                    dictionaryAudio = dictionary;
                else
                    disp('+ Loading dictionary...');
                    dictionaryAudio = load(matdic);
                    dictionaryAudio = dictionaryAudio.dictionary;
                end
                kinddata = 'video';
            else
                dictionaryAudio = [];
            end
        else
            matdic = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryName, vK(i)));
            if createDictionary && (~skipIfDone || (skipIfDone && ~exist(matdic, 'file')))
                disp('+ Computing dictionary...');
                dictionary = mj_createDictionaryGen(featuresPath, partitions_dic, vK(i), cams, trajectories, sequences, kinddic, dicpars);
                %matdets = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryName, vK(i)));
                save(matdic, 'dictionary');
            else
                disp('+ Loading dictionary...');
                dictionary = load(matdic);
                dictionary = dictionary.dictionary;
            end
        end

        % Calculating histograms.
        disp('+ Loading training data...');
        if earlyFusion
            rgb = struct('featuresPath', featuresPathRGB, 'tracksPath', tracksPathRGB, 'partitions_train', partitions_trainRGB, 'dictionary', dictionaryRGB, 'dbname', dbnameRGB, 'doPCA', doPCARGB);
            depth = struct('featuresPath', featuresPathDepth, 'tracksPath', tracksPathDepth, 'partitions_train', partitions_trainDepth, 'dictionary', dictionaryDepth, 'dbname', dbnameDepth, 'doPCA', doPCADepth);
            audio = struct('featuresPath', featuresPathAudio, 'tracksPath', tracksPathAudio, 'partitions_train', partitions_trainAudio, 'dictionary', dictionaryAudio, 'dbname', dbnameAudio, 'doPCA', doPCAAudio);
            parameters = struct('RGB', rgb, 'Depth', depth, 'Audio', audio);
            parameters.kindPooling = kindPooling;
            parameters.K = vK(i);
            parameters.KAudio = vKAudio(i);
            parameters.KDepth = vKDepth(i);
            parameters.subjects = [subjectsTst];
            parameters.train = 1;
            parameters.doPCAHRGB = doPCAHRGB;
            parameters.doPCAHAudio = doPCAHAudio;
            parameters.doPCAHDepth = doPCAHDepth;
            [histograms, labels, dictionaryFusion, ~, ~, pcaobjRGB, pcaobjDepth, pcaobjAudio] = fc_computeEarlyFusion(parameters, cams, trajectories, sequences, kinddic, encpars, sources, kindFusion);
            if ~isempty(dictionaryFusion)
                matdicfus = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', 'dictionaryBiModalFusion', vK(i)));
                save(matdicfus, 'dictionaryFusion');
            end
        else
            if mj_isGaitPyramid(partitions_train)
                [histograms, labels] = mj_calculateHistogramsPyrGen(featuresPath, tracksPath, partitions_train, dictionary, cams, trajectories, sequences, kinddic, encpars);
            else
                [histograms, labels] = mj_calculateHistogramsGen(featuresPath, tracksPath, partitions_train, dictionary, cams, trajectories, sequences, kinddic, encpars);
            end
        end

        % Options
        learnpars.doPCAH = doPCAH;
        learnpars.doML = doML;
        % Metric Learning parameters
        mlpars.class = mlmodel; % Opts: {'ClassUnreg', 'JointClassUnreg'}
        mlpars.params = [0.01, 10];
        mlpars.numIter = 15*10^4;
        mlpars.logStep = 10^4;
        learnpars.mlpars = mlpars;
        learnpars.matml = fullfile(svmOutputdir, sprintf('%s_K=%04d%s_nFrames=%04d_overlap=%02d.mat', matmlName,  K, expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));
        % SVM cross-validation parameters
        cvpars.nfolds = 4;
        cvpars.finalTrain = 0;
        cvpars.verbose = 1;
        learnpars.cvpars = cvpars;
        % Classifier params
        learnpars.vC = vC;
        learnpars.kindclassif = kindclassif;
        learnpars.confSVM = conf;
        learnpars.K = K;
        
        % Parameters for bagging and random subspace.
        if exist('TF', 'var') && exist('TS', 'var')
            learnpars.TF = TF;
            learnpars.TS = TS;
        end

        % Do it!
        [bestModel, info, histograms] = mj_trainAndTuneClassifier(histograms, labels, learnpars, verbose);
        model = struct('model', bestModel, 'C', info.C);

        % Save samples
        if true
            matsamples = fullfile(samplesOutputdir, sprintf('train_K=%04d_nFrames=%04d_overlap=%02d_%s.mat', K, partitions_train(1).nFrames, partitions_train(1).overlap, kinddata));
            save(matsamples, 'histograms', 'labels');
        end

        if earlyFusion
            model.model.pcaobj = pcaobjRGB;
            model.model.pcaobjAudio = pcaobjAudio;
            model.model.pcaobjDepth = pcaobjDepth;
        end

        save(matmodel, 'model');
    end % i
end


% % File: mj_trainGaitGen.m
% %
% % Learn a model to classify people using motion flows.
% % First version by FMCP
% % MOD, mjmarin, Nov/2013: this version uses Fisher Vectors
%
% verbose = 1;
%
% %avaSubjects;
%
% % -------------------- Parameters -------------------- %
% % if isunix
% %    if useOldDirs
% %       %experdir = '/data/mjetal/';
% %       experdir = '/data/experiments/casiaB/silhouettes/';
% %    else
% %       %experdir = '/home/cifs/mjetal/experiments/gait/';
% % 	experdir = '/data/mjetal/experiments/casiaB/silhouettes/';
% % 	%experdir = '/data/mjetal/experiments/casiaC/';
% %    end
% % else
% %    if ~isUCOpc
% %       experdir = 'D:\experiments\gait\';
% %    else
% %       experdir = 'F:\experiments\gait\';
% %    end
% % end
%
% %% Define directories
% mj_gaitLocalPaths;
%
% if ~exist('kinddic', 'var')
%    kinddic = 'fv';
% end
%
% switch kinddic
%    case 'fv'
%       outdirbase = fullfile(experdir, 'fv');
%    case 'bow'
%       outdirbase = fullfile(experdir, 'bow');
%    otherwise
%       error('Invalid kinddic');
% end
% featuresPath = fullfile(experdir, 'tracked_dense_feats'); % Path of the samples.
% tracksPath = fullfile(experdir, 'tracks'); % Path of the tracks.
% outputName = 'full_model';  % Name of the model file saved.
% dictionaryName = 'full_dictionary'; % Name of the dictionary file.
% conf.svm.biasMultiplier = 1;    % Configuration of the SVM.
% vC = [1,10,50,100]; % Possible C values for SVM
% % -------------------- Parameters -------------------- %
%
% if ~exist('kindclassif', 'var')
%    kindclassif = 'svmlin';      % svmlin is good for FV, but svmchi2 is more suitable for BOW
% end
%
% if ~exist('doPCA','var')
%    doPCA = 0;
% end
%
% if ~exist('doPCAH','var')
%    doPCAH = 0;
% end
%
% if ~exist('doML','var')
%    doML = 0;
% end
%
% if ~exist('doDTsel', 'var')
%    doDTsel = 0;
% end
%
% % Check if createDictionary exists.
% if ~exist('createDictionary', 'var')
%     createDictionary = 0;
% end
%
% if ~exist('skipIfDone', 'var')
%    skipIfDone = false;
% end
%
% if ~exist('vK', 'var')
%     vK = [50];
% end
%
% % Check if cams exists.
% if ~exist('cams', 'var')
%     cams = 90;
% end
%
% % Check if trajectories exists.
% if ~exist('trajectories', 'var')
%     trajectories = 'nm';
% end
%
% % Check if sequences exists.
% if ~exist('sequences', 'var')
%     sequences = [1 2 3 4];
% end
%
% if ~exist('ftdims', 'var')
%    ftdims = [30 96 96 96];
% end
%
% if ~exist('sqrtsel', 'var')
%    sqrtsel = [0 1 1 1];
% end
%
% % Check available partitions
% mj_defaultPartitionsTrainGait;
%
% % Prepare experiment name
% if ~isempty(cams)
%    cams = sort(cams);
%    cams_str = sprintf('%03d', cams(1));
%    for i=2:length(cams)
%       cams_str = [cams_str, '_', sprintf('%03d', cams(i))];
%    end
% else
%    cams_str = '';
% end
%
% sequences = sort(sequences);
% sequences_str = sprintf('%02d', sequences(1));
% for i=2:length(sequences)
%     sequences_str = [sequences_str, '_', sprintf('%02d', sequences(i))];
% end
%
% trajectories_str = trajectories;
%
% fprintf('Trajectory = %s, Sequence = %s, Camera = %s \n', trajectories_str, sequences_str, cams_str);
%
% extrafix = '';
% if doDTsel > 0
%    extrafix = [extrafix sprintf('_DTs%02d', round(doDTsel*100))];
% end
%
% if doPCA > 0
%    extrafix = [extrafix sprintf('_PCA%03d', doPCA)];
% end
%
% doSqrt = ~isempty(sqrtsel)  && any(sqrtsel);
% if doSqrt
%    extrafix = [extrafix, '_sq'];
% end
% [extrafixdir, extrafixexper] = mj_buildPartsString(partitions_train);
% % if length(partitions_train(1).partition) == 1
% %    extrafix = [extrafix sprintf('_part%02d', partitions_train(1).partition)];
% % end
% extrafix = [extrafix, extrafixdir];
%
% outdir = fullfile(outdirbase, sprintf('trj%sseq%scam%s%s', trajectories_str, sequences_str, cams_str, extrafix));
% if ~exist(outdir,'dir')
%     mkdir(outdir);
% end
%
% svmOutputdir = fullfile(outdir, 'models'); % Directory to save the model.
% if ~exist(svmOutputdir,'dir')
%     mkdir(svmOutputdir);
% end
%
% dictionariesOutputdir = fullfile(outdir, 'dictionaries'); % Directory to save dictionaries.
% if ~exist(dictionariesOutputdir,'dir')
%     mkdir(dictionariesOutputdir);
% end
%
% samplesOutputdir = fullfile(outdir, 'samples'); % Directory to save the samples
% if ~exist(samplesOutputdir,'dir')
%     mkdir(samplesOutputdir);
% end
%
% dicpars.doPCA = doPCA;
% dicpars.vdims = ftdims; % Def. [30 96 96 96] for DCS
% dicpars.sqrt = sqrtsel;
% dicpars.dbname = dbname;
% dicpars.doDTsel = doDTsel;
% dicpars.subjects = subjectsTrn;
%
% encpars.ftdims = dicpars.vdims;
% encpars.ftsel = [1 1 1 1]; %[0 1 1 1];   % Def. [1 1 1 1]
% encpars.sqrt = sqrtsel;
% encpars.dbname = dbname;
% encpars.doDTsel = doDTsel;
% encpars.subjects = subjectsTst;
%
% if strcmp(kindclassif, 'svmlin')
%    conf.normalize = 1; % Normalize data during training/testing
% end
%
% expernamefix = '';
% % if isfield(partitions_train, 'join') && any([partitions_train.join] > 0)
% %    expernamefix = [expernamefix '_jn'];
% % end
% expernamefix = [expernamefix, extrafixexper];
%
% if doPCAH > 0
%    expernamefix = [expernamefix sprintf('_PCAH%03d', doPCAH)];
% end
% if doML > 0
%    expernamefix = [expernamefix sprintf('_ML%03d', doML)];
% end
%
% % Loop over dictionary size
% for i = 1:length(vK)
%     K = vK(i);
%     matmodel = fullfile(svmOutputdir,...
%         sprintf('%s_%s_K=%04d%s_nFrames=%04d_overlap=%02d.mat', outputName, kindclassif, K, expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));
%
%    if exist(matmodel, 'file') && skipIfDone
%        disp('+ Model already exists. Skipping...');
%        continue
%    end
%    matdic = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryName, vK(i)));
%    if createDictionary && (~skipIfDone || (skipIfDone && ~exist(matdic, 'file')))
%         disp('+ Computing dictionary...');
%         dictionary = mj_createDictionaryGen(featuresPath, partitions_dic, vK(i), cams, trajectories, sequences, kinddic, dicpars);
%         %matdets = fullfile(dictionariesOutputdir, sprintf('%s_K=%04d.mat', dictionaryName, vK(i)));
%         save(matdic, 'dictionary');
%     else
%         disp('+ Loading dictionary...');
%         dictionary = load(matdic);
%         dictionary = dictionary.dictionary;
%     end
%
%     % Calculating histograms.
%     disp('+ Loading training data...');
%     if mj_isGaitPyramid(partitions_train)
%        [histograms, labels] = mj_calculateHistogramsPyrGen(featuresPath, tracksPath, partitions_train, dictionary, cams, trajectories, sequences, kinddic, encpars);
%     else
%        [histograms, labels] = mj_calculateHistogramsGen(featuresPath, tracksPath, partitions_train, dictionary, cams, trajectories, sequences, kinddic, encpars);
%     end
%
% 	% Save samples
% if false
% 	matsamples = fullfile(samplesOutputdir, sprintf('train_%s_K=%04d_nFrames=%04d_overlap=%02d.mat', outputName, K, partitions_train(1).nFrames, partitions_train(1).overlap));
% 	save(matsamples, 'histograms', 'labels');
% end
%
%    % Options
%    learnpars.doPCAH = doPCAH;
%    learnpars.doML = doML;
%    % Metric Learning parameters
%    mlpars.class = 'ClassUnreg'; % Opts: {'ClassUnreg', 'JointClassUnreg'}
%    mlpars.params = [0.01, 10];
%    mlpars.numIter = 15*10^4;
%    mlpars.logStep = 10^4;
%    learnpars.mlpars = mlpars;
%    learnpars.matml = fullfile(svmOutputdir, sprintf('%s_K=%04d%s_nFrames=%04d_overlap=%02d.mat', 'ml_model',  K, expernamefix, partitions_train(1).nFrames, partitions_train(1).overlap));
%    % SVM cross-validation parameters
%    cvpars.nfolds = 3;
%    cvpars.finalTrain = 0;
%    cvpars.verbose = 1;
%    learnpars.cvpars = cvpars;
%    % Classifier params
%    learnpars.vC = vC;
%    learnpars.kindclassif = kindclassif;
%    learnpars.confSVM = conf;
%
%    % Do it!
%    [bestModel, info] = mj_trainAndTuneClassifier(histograms, labels, learnpars, verbose);
%    model = struct('model', bestModel, 'C', info.C);
%
%    save(matmodel, 'model');
% end % i
