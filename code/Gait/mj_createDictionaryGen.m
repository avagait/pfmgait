function dictionary = mj_createDictionaryGen(featuresPath, partitions, K, cams, trajectories, sequences, kind, pars)
% function dictionary = mj_createDictionaryAudio(featuresPath, partitions, K, cams, trajectories, kind, pars)
% Learn a dictionary using Bag of Words or Fisher Vectors.
%
% Input:
%  - featuresPath: Path of the directory that contains all features. The directory must contain one folder for every person.
%  - partitions: Struct array with partitions. Fields:
%        - partition. Index of partition to be used.
%        - nHorizontalPartitions. Number of horizontal partitions that
%        contains the file.
%        - nVerticalPartitions. Number of vertical partitions that
%        contains the file.
%        - mirror. If it's set to 1, the mirrored data is used.
%        - nFrames. Number of frames for time splitting.
%        - overlap. Numver of overlap frames for time splitting.
%  - K: Number of centroids.
%  - cams: Column array with the number of cams used.
%  - trajectories: Column array with the number of trajectories used. 
%  - kind: Kind of dictionary.
%        - 'bow'. Bow dictionary.
%        - 'fv'. FV dictionary.
%  - pars: struct with fields:
%     .doPCA: compute PCA over features to reduce dimensionality? Only valid for FV
% Output:
%  - dictionary: Learned dictionary.
%
% See also calculateBOWHistograms, FV class

% Versions: 
%  - 2/Dec/2013: new parameter 'pars' for extra parameters.
%  - 14/May/2014: limited number of samples for dictionary, to avoid Out of Memory error
%  - 16/Dic/2014: handle sqrt of low-level features

if ~exist('pars','var')
   pars = [];
end

if isempty(pars)
   pars.doPCA = 0;
end

if ~isfield(pars, 'sqrt')
   pars.sqrt = [];
end

if ~isfield(pars, 'dbname')
   pars.dbname = 'ava';
end

if ~isfield(pars, 'doDTsel')
   pars.doDTsel = 0;
end

if ~isfield(pars, 'kinddata')
   pars.kinddata = 'video';
end

% Increase compatibility
if ~ischar(cams)
   cams_ = '';
   for i = 1:length(cams)
      cams_(i,:) = sprintf('%03d', cams(i));
   end   
   cams = cams_;
end

% Increase compatibility
if ~ischar(sequences)
   sequences_ = '';
   for i = 1:length(sequences)
      sequences_(i,:) = sprintf('%02d', sequences(i));
   end   
   sequences = sequences_;
end

% Define sampling ratio
srat = 1.0 / (2*size(cams,1)*size(trajectories,1));
hardLimit = 400000; % DEVELOP: max number of samples

totalFeatures = mj_loadFeatPartitionsGen(pars.dbname, featuresPath, partitions, cams, trajectories, sequences, pars);

fprintf('\n* Loading data from %d configurations...', length(totalFeatures));

mTrain = [];
for i=1:length(totalFeatures)
    for j=1:length(totalFeatures(i).feats)
        % Loading dense_feats of the given part.
        features = load(fullfile(featuresPath, totalFeatures(i).feats(j).name));
        if strcmp('audio', pars.kinddata)
            features = features.feats;
        else
            features = features.detections;
        end
        
        if pars.doDTsel
           features = mj_selectKeyDTs(features, pars.doDTsel);
        end
        
        if ~strcmp('audio', pars.kinddata)
            matrix = fc_calculateFeatsMatrix(features, totalFeatures(i).partition);
            if iscell(matrix)
               matrix = cell2mat(matrix);
            end
        else
            matrix = features;
        end
        if srat < 1 % Subsampling?
           nsamples = size(matrix,2);
           rp = randperm(nsamples);
           matrix = matrix(:,rp(1:floor(nsamples*srat)));
        end
        mTrain = [mTrain matrix];
    end
    
    if size(mTrain,2) > hardLimit
       mTrain = mTrain(:,1:2:end); % Keep half
    end
end
fprintf(' done! \n');

if isempty(mTrain)
   error('Could not read samples to learn a dictionary. Please, check the paths.');
end

%% Pre-process features?
if strcmp('audio', pars.kinddata)
    % Normalize?
    nm = [];
    if pars.doNormAudio
        nm = NM(mTrain');
        nm.clearData();
        
        mTrain = nm.encodeZCA(mTrain');
        mTrain = mTrain';
    end
end

doSqrt = ~isempty(pars.sqrt) && any(pars.sqrt);   
if doSqrt
   lms = mj_splitFeatVector(mTrain', pars.vdims, pars.sqrt);
   mTrain = mj_joinFeatVectors(lms);
   mTrain = mTrain';
end

%% Learn dictionary
if strcmp('fv', kind)
    % Calculating FV.
    fv = FV(mTrain, K, pars.doPCA);
    fv.clearData();   % Release memory
    dictionary = fv;
elseif strcmp('bow', kind)
    % Calculating BOW.
    [centroids, idx, energ] = vl_kmeans(mTrain, K, 'distance', 'l2', 'algorithm', 'elkan', 'initialization', 'plusplus', 'numrepetitions', 3);
    dictionary = centroids;
else
    dictionary = -1;
end

% function dictionary = mj_createDictionaryGen(featuresPath, partitions, K, cams, trajectories, sequences, kind, pars)
% % function dictionary = mj_createDictionaryGen(featuresPath, partitions, K, cams, trajectories, kind, pars)
% % Learn a dictionary using Bag of Words or Fisher Vectors.
% %
% % Input:
% %  - featuresPath: Path of the directory that contains all features. The directory must contain one folder for every person.
% %  - partitions: Struct array with partitions. Fields:
% %        - partition. Index of partition to be used.
% %        - nHorizontalPartitions. Number of horizontal partitions that
% %        contains the file.
% %        - nVerticalPartitions. Number of vertical partitions that
% %        contains the file.
% %        - mirror. If it's set to 1, the mirrored data is used.
% %        - nFrames. Number of frames for time splitting.
% %        - overlap. Numver of overlap frames for time splitting.
% %  - K: Number of centroids.
% %  - cams: Column array with the number of cams used.
% %  - trajectories: Column array with the number of trajectories used. 
% %  - kind: Kind of dictionary.
% %        - 'bow'. Bow dictionary.
% %        - 'fv'. FV dictionary.
% %  - pars: struct with fields:
% %     .doPCA: compute PCA over features to reduce dimensionality? Only valid for FV
% % Output:
% %  - dictionary: Learned dictionary.
% %
% % See also calculateBOWHistograms, FV class
% 
% % Versions: 
% %  - 2/Dec/2013: new parameter 'pars' for extra parameters.
% %  - 14/May/2014: limited number of samples for dictionary, to avoid Out of Memory error
% %  - 16/Dic/2014: handle sqrt of low-level features
% 
% if ~exist('pars','var')
%    pars = [];
% end
% 
% if isempty(pars)
%    pars.doPCA = 0;
% end
% 
% if ~isfield(pars, 'sqrt')
%    pars.sqrt = [];
% end
% 
% if ~isfield(pars, 'dbname')
%    pars.dbname = 'ava';
% end
% 
% if ~isfield(pars, 'doDTsel')
%    pars.doDTsel = 0;
% end
% 
% % Increase compatibility
% if ~ischar(cams)
%    cams_ = '';
%    for i = 1:length(cams)
%       cams_(i,:) = sprintf('%03d', cams(i));
%    end   
%    cams = cams_;
% end
% 
% % Increase compatibility
% if ~ischar(sequences)
%    sequences_ = '';
%    for i = 1:length(sequences)
%       sequences_(i,:) = sprintf('%02d', sequences(i));
%    end   
%    sequences = sequences_;
% end
% 
% % Define sampling ratio
% srat = 1.0 / (2*size(cams,1)*size(trajectories,1));
% hardLimit = 400000; % DEVELOP: max number of samples
% 
% % Locating dense_feats with cams and trajectories.
% % totalFeatures = [];
% % for i=1:length(partitions)
% %     for j=1:size(cams, 1)
% %         for k=1:size(trajectories, 1)
% %             if partitions(i).mirror
% %                 pattern = sprintf('*tr%s_cam%s_W%02d_H%02d_M.mat', trajectories(k, :), cams(j, :), partitions(i).nHorizontalPartitions, partitions(i).nVerticalPartitions); 
% %             else
% %                 pattern = sprintf('*tr%s_cam%s_W%02d_H%02d.mat', trajectories(k, :), cams(j, :), partitions(i).nHorizontalPartitions, partitions(i).nVerticalPartitions);
% %             end
% %             
% %             % Loading dense_feats and assigning their partitions.
% %             features.feats = dir(fullfile(featuresPath, pattern));
% %             features.partition = partitions(i).partition;
% %             totalFeatures = [totalFeatures ; features];
% %         end
% %     end
% % end
% 
% %totalFeatures = mj_loadFeatPartitionsCASIA(featuresPath, partitions, cams, trajectories, sequences); % Added by mjmarin: replaces previous code
% totalFeatures = mj_loadFeatPartitionsGen(pars.dbname, featuresPath, partitions, cams, trajectories, sequences, pars);
% 
% fprintf('\n* Loading data from %d files...', length(totalFeatures));
% 
% mTrain = [];
% for i=1:length(totalFeatures)
%     for j=1:length(totalFeatures(i).feats)
%         % Loading dense_feats of the given part.
%         features = load(fullfile(featuresPath, totalFeatures(i).feats(j).name));
%         features = features.detections;
%         
%         if pars.doDTsel
%            features = mj_selectKeyDTs(features, pars.doDTsel);
%         end
%         
%         matrix = fc_calculateFeatsMatrix(features, totalFeatures(i).partition);
%         if iscell(matrix)
%            matrix = cell2mat(matrix);
%         end
%         if srat < 1 % Subsampling?
%            nsamples = size(matrix,2);
%            rp = randperm(nsamples);
%            matrix = matrix(:,rp(1:floor(nsamples*srat)));
%         end
%         mTrain = [mTrain matrix];
%     end
%     
%     if size(mTrain,2) > hardLimit
%        mTrain = mTrain(:,1:2:end); % Keep half
%     end
% end
% fprintf(' done! \n');
% 
% if isempty(mTrain)
%    error('Could not read samples to learn a dictionary. Please, check the paths.');
% end
% 
% %% Pre-process features?
% doSqrt = ~isempty(pars.sqrt) && any(pars.sqrt);   
% if doSqrt
%    lms = mj_splitFeatVector(mTrain', pars.vdims, pars.sqrt);
%    mTrain = mj_joinFeatVectors(lms);
%    mTrain = mTrain';
% end
% 
% %% Learn dictionary
% if strcmp('fv', kind)
%     % Calculating FV.
%     fv = FV(mTrain, K, pars.doPCA);
%     fv.clearData();   % Release memory
%     dictionary = fv;
% elseif strcmp('bow', kind)
%     % Calculating BOW.
%     [centroids, idx, energ] = vl_kmeans(mTrain, K, 'distance', 'l2', 'algorithm', 'elkan', 'initialization', 'plusplus', 'numrepetitions', 3);
%     dictionary = centroids;
% else
%     dictionary = -1;
% end
%     
