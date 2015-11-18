function [histograms, labels, lfiles, id_videos] = mj_calculateHistogramsGen(featuresPath, tracksPath, partitions, dictionary, cams, trajectories, sequences, kind, pars)
% function [histograms, labels, lfiles, id_videos] = mj_calculateHistogramsGen(featuresPath, partitions, dictionary, cams, trajectories, kind, pars)
% Use the learned dictionary to calculate the histograms used in Fisher
% Vectors or Bag of Words.
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
%        - overlap. Number of overlapping frames for time splitting.
%        - join: merge local features insteado keeping separated spatial divisions? Def. 0 (=use spatial partitions)
%  - dictionary: Learned dictionary.
%  - cams: Column array with the number of cams used.
%  - trajectories: Column array with the number of trajectories used.
%  - kind: Kind of dictionary.
%        - 'bow'. Bow dictionary.
%        - 'fv'. FV dictionary.
%  - pars: struct with fields
%      .ftdims: vector with dimensions of each type of feature
%      .ftsel: boolean vector with selected features
%      .sqrt: boolean vector to compute sqrt on low-level features. Only valid if multi-dictionary
%      .onlyct: extract only central subsequence
%
% Output:
%  - histograms: Calculated histograms.
%  - labels: Column array with labels of every histogram.
%  - lfiles: Array with names of video files used.
%  - id_videos: Unique id for every video file.
%
% See also createBOWDictionary, FV class

% Versions:
%  - 03/Apr/2014: mjmarin, added new parameters 'pars' to easily include
%  new parameters for encoding
%
%  - 19/Dic/2014: mjmarin, added opt 'doDTsel' for filtering Dense Tracks

if ~exist('pars', 'var')
    pars = [];
end

if isempty(pars)
    pars.ftdims = [];
    pars.ftsel = 1;
    pars.ftsqrt = [];
    pars.onlyct = 0;
    pars.dbname = 'casia';
    pars.doDTsel = 0;
    pars.kinddata = 'visual';
    pars.newSamples = 0;
    pars.newSamplesBand = 0;
end

if ~isfield(pars, 'kinddata')
    pars.kinddata = 'visual';
end

if ~isfield(pars, 'newSamplesBand')
    pars.newSamplesBand = 0;
end

if ~isfield(pars, 'newSamples')
    pars.newSamples = 0;
end

if ~isfield(pars, 'onlyct')
    pars.onlyct = 0;
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

totalFeatures = mj_loadFeatPartitionsGen(pars.dbname, featuresPath, partitions, cams, trajectories, sequences, pars);

histograms = [];
labels = [];
id_videos = [];
this_vid = 0;   % Counter
lfiles = cell(length(totalFeatures), 1); % Output filenames
for i=1:length(totalFeatures) % Video files.
    jlabels = [];
    jhistograms = [];
    jid_videos = [];
    ilfeats = totalFeatures(i).feats;
    nilfeats = length(ilfeats);
    for j=1:nilfeats % Features of a video file.
        % Find label.
        if isfield(pars, 'labels')
            label = mj_gaitLabFromName(pars.dbname, ilfeats(j).name, pars.labels);
        else
            label = mj_gaitLabFromName(pars.dbname, ilfeats(j).name, []);
        end
        
        % Obtaining features.
        matfeats = fullfile(featuresPath, ilfeats(j).name);
        try
            features = load(matfeats);
        catch
            disp(['WARN: cannot read file ' matfeats]);
            features.detections = [];
        end
        
        if isfield(pars, 'kinddata') && strcmp('audio', pars.kinddata)
            features = features.feats;
            if pars.doNormAudio
                nm = NM(features');
                nm.clearData();
                features = nm.encodeZCA(features');
                features = features';
            end
        else
            features = features.detections;
        end
        
        if pars.doDTsel
            features = mj_selectKeyDTs(features, pars.doDTsel);
        end
        
        % Computing new partitions.
        if ~isempty(totalFeatures(i).moreHorizontalPartitions) || ~isempty(totalFeatures(i).moreVerticalPartitions)
            grid.horizontal = totalFeatures(i).moreHorizontalPartitions;
            grid.vertical = totalFeatures(i).moreVerticalPartitions;
            params.offset = 20;
            % Loading tracks.
            tracks_file = fullfile(tracksPath, sprintf('%s.mat', parts{1}));
            tracks = load(tracks_file);
            tracks = tracks.detections;
            array = cell(length(features), 1);
            for feats = 1:length(features)
                array{feats} = fc_fitFeatures(features{feats}, tracks.tracks(1), grid, params);
            end
            
            features = cell(length(totalFeatures(i).moreHorizontalPartitions) * length(totalFeatures(i).moreVerticalPartitions) * length(features), 1);
            index = 1;
            
            % Sorting the array according to the established order.
            for horBlocks = 0:length(array{1}) / length(totalFeatures(i).moreHorizontalPartitions)
                for feats = 1:length(array)
                    for pos = 1:length(array{1}) / length(totalFeatures(i).moreHorizontalPartitions)
                        features{index} = array{feats}{(horBlocks * (length(array{1}) / length(totalFeatures(i).moreHorizontalPartitions)) + pos)};
                        index = index + 1;
                    end
                end
            end
        end
        
        if isempty(features)
            disp(['WARN: empty data in ' lfiles{i}]);
        else
            this_vid = this_vid + 1; % Next id for video
            lfiles{this_vid} = ilfeats(j).name; % Get filename
            % Time split.
            if totalFeatures(i).nFrames > 0
                lfeatures = []; % Just in case using multi-partition
                if length(totalFeatures(i).partition) > 1
                    if totalFeatures(i).join
                        for ptx = 1:length(totalFeatures(i).partition)
                            if ptx == 1
                                lfeatures{ptx} = mj_calculateTimePartition(features{totalFeatures(i).partition(ptx)}, totalFeatures(i).nFrames, totalFeatures(i).overlap, pars.onlyct);
                            else
                                lfeatures_temp = mj_calculateTimePartition(features{totalFeatures(i).partition(ptx)}, totalFeatures(i).nFrames, totalFeatures(i).overlap, pars.onlyct);
                                if length(lfeatures_temp) == length(lfeatures{1})
                                    for i_ = 1:length(lfeatures_temp)
                                        tmp = [lfeatures{1}{i_}, lfeatures_temp{i_}];
                                        lfeatures{1}{i_} = tmp;
                                    end % i_
                                end % if
                            end % if
                        end % ptx
                    else % Classic mode
                        for ptx = 1:length(totalFeatures(i).partition)
                            lfeatures{ptx} = mj_calculateTimePartition(features{totalFeatures(i).partition(ptx)}, totalFeatures(i).nFrames, totalFeatures(i).overlap, pars.onlyct);
                        end % ptx
                    end % if-join
                else % Single partition, as done by FMCP
                    lfeatures{1} = mj_calculateTimePartition(features{totalFeatures(i).partition}, totalFeatures(i).nFrames, totalFeatures(i).overlap, pars.onlyct);
                end
                
                jhistograms_p = [];
                for ptx = 1:length(lfeatures),
                    features = lfeatures{ptx};
                    jhistograms_ = [];
                    for k=1:length(features) % Time parts.
                        if pars.newSamplesBand > 0
                            matrices = fc_generateNewSamples(features(k), pars.percent, 0, pars.newSamplesBand);
                            for nmatr=1:length(matrices)
                                if ~isempty(matrices{nmatr})
                                    matrix = fc_calculateFeatsMatrix(matrices(nmatr), 1);
                                    if ~isempty(matrix)
                                        h = mj_encodeFV(matrix, dictionary, pars);
                                        jhistograms_ = [jhistograms_ ; h'];
                                    end
                                end
                            end
                        end
                        % Obtaining features of the desired partitions.
                        matrix = fc_calculateFeatsMatrix(features, k);
                        if ~isempty(matrix)
                            % Encode with Fisher Vector
                            if strcmp('fv', kind)
                                if pars.newSamples > 0
                                    matrices = fc_generateNewSamples(matrix, pars.percent, pars.newSamples, 0);
                                    for nmatr=1:length(matrices)
                                        h = mj_encodeFV(matrices{nmatr}, dictionary, pars);
                                        jhistograms_ = [jhistograms_ ; h'];
                                    end
                                else
                                    h = mj_encodeFV(matrix, dictionary, pars);
                                    jhistograms_ = [jhistograms_ ; h'];
                                end
                            elseif strcmp('bow', kind)
                                % Calculating distances between feats and centroids.
                                D = vl_alldist2(matrix, dictionary);
                                % Calculating histograms.
                                khistogram = zeros(1, size(dictionary, 2));
                                for l=1:size(D, 1)
                                    [C, I] = min(D(l, :));
                                    khistogram(1, :) = vl_binsum(khistogram(1, :), 1, I(1));
                                end

                                % Normalize histograms.
                                khistogram(1, :) = khistogram(1, :) / sum(khistogram(1, :));

                                jhistograms_ = [jhistograms_ ; khistogram];
                            end % if
                        end
                    end % k
                    if ~isempty(jhistograms_p)
                        if size(jhistograms_p,1) == size(jhistograms_,1)
                            jhistograms_p = [jhistograms_p, jhistograms_];
                        else
                            disp(['Invalid sequence for concatenation: ' matfeats]);
                            % Fix. Remove data.
                            if size(jhistograms_p,1) > size(jhistograms_,1)
                                dif = size(jhistograms_p,1) - size(jhistograms_,1);
                                jhistograms_p = jhistograms_p(1:end-dif, :);
                            else
                                dif = size(jhistograms_,1) - size(jhistograms_p,1);
                                jhistograms_ = jhistograms_(1:end-dif, :);
                            end
                            jhistograms_p = [jhistograms_p, jhistograms_];
                            %jhistograms_p = [];
                            break
                        end
                    else
                        jhistograms_p = [jhistograms_p, jhistograms_];
                    end % if
                end % ptx
                jhistograms = [jhistograms; jhistograms_p];
                jlabels = [jlabels ; label+zeros(size(jhistograms_p,1),1)];
                jid_videos = [jid_videos; this_vid+zeros(size(jhistograms_p,1),1)];
            else % Take whole sequence to compute descriptor
                % Obtaining features of the desired partitions.
                if ~strcmp('audio', pars.kinddata)
                    if pars.newSamplesBand > 0
                        hfinal = [];
                        for parti=1:length(features)
                            matrices = fc_generateNewSamples(features(parti), 0, 0, pars.newSamplesBand);
                            h_ = [];
                            for nmatr=1:length(matrices)
                                matrix = fc_calculateFeatsMatrix(matrices(nmatr), 1);
                                h = mj_encodeFV(matrix, dictionary, pars);
                                h_ = [h_ ; h'];
                            end
                            hfinal = [hfinal, h_];
                        end
                        jhistograms = [jhistograms; hfinal];
                    end
                    matrix = fc_calculateFeatsMatrix(features, totalFeatures(i).partition);
                    if totalFeatures(i).join
                        matrix = cell2mat(matrix);
                    end
                else
                    matrix = features;
                end
                
                if ~isempty(matrix) % Deal with no data
                    %jlabels = [jlabels ; label];
                    %jid_videos = [jid_videos; this_vid];
                    
                    if strcmp('fv', kind)
                        if iscell(matrix) % Several partitions
                            h = [];
                            % Encode with Fisher Vector
                            if pars.newSamples > 0
                                for ixmt = 1:length(matrix)
                                    matrices = fc_generateNewSamples(matrix{ixmt}, pars.percent, pars.newSamples, 0);
                                    h2 = [];
                                    for nmatr=1:length(matrices)
                                        h_ = mj_encodeFV(matrices{nmatr}, dictionary, pars);
                                        h2 = [h2, h_];
                                    end
                                    h = [h; h2];
                                end
                            else
                                for ixmt = 1:length(matrix)
                                    h_ = mj_encodeFV(matrix{ixmt}, dictionary, pars);
                                    h = [h; h_];
                                end
                            end
                            jhistograms = [jhistograms ; h'];
                        else
                            % Encode with Fisher Vector
                            if pars.newSamples > 0 
                                matrices = fc_generateNewSamples(matrix, pars.percent, pars.newSamples, 0);
                                for nmatr=1:length(matrices)
                                    h = mj_encodeFV(matrices{nmatr}, dictionary, pars);
                                    jhistograms = [jhistograms ; h'];
                                end
                            else
                                h = mj_encodeFV(matrix, dictionary, pars);
                                jhistograms = [jhistograms ; h'];
                            end
                        end
                    elseif strcmp('bow', kind)
                        if iscell(matrix) % Several partitions
                            khistogram = [];
                            for  ixmt = 1:length(matrix)
                                khistogram_ = singleBOWnorm(matrix{ixmt}, dictionary);
                                khistogram = [khistogram, khistogram_];
                            end % ixmt
                            
                            jhistograms = [jhistograms ; khistogram];
                        else
                            khistogram = singleBOWnorm(matrix, dictionary); % mjmarin: added function to simplify code
                            jhistograms = [jhistograms ; khistogram];
                        end
                    end
                    
                    jlabels = [jlabels ; label+zeros(size(jhistograms,1) - length(jlabels),1)];
                    jid_videos = [jid_videos; this_vid+zeros(size(jhistograms,1) - length(jid_videos),1)];
                end % if-empty(matrix)
            end
        end
    end
    
    labels = [labels ; jlabels];
    id_videos = [id_videos ; jid_videos];
    histograms = [histograms ; jhistograms];
end


% Private functions
% ------------------------------------------------------
function khistogram = singleBOWnorm(matrix, dictionary)

D = vl_alldist2(matrix, dictionary);
% Calculating histograms.
khistogram = zeros(1, size(dictionary, 2));
for k=1:size(D, 1)
    [C, I] = min(D(k, :));
    khistogram(1, :) = vl_binsum(khistogram(1, :), 1, I(1));
end

% Normalize histograms.
khistogram(1, :) = khistogram(1, :) / sum(khistogram(1, :));


% function [histograms, labels, lfiles, id_videos] = mj_calculateHistogramsGen(featuresPath, tracksPath, partitions, dictionary, cams, trajectories, sequences, kind, pars)
% % function [histograms, labels, lfiles, id_videos] = mj_calculateHistogramsGen(featuresPath, partitions, dictionary, cams, trajectories, kind, pars)
% % Use the learned dictionary to calculate the histograms used in Fisher
% % Vectors or Bag of Words.
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
% %        - overlap. Number of overlapping frames for time splitting.
% %        - join: merge local features insteado keeping separated spatial divisions? Def. 0 (=use spatial partitions)
% %  - dictionary: Learned dictionary.
% %  - cams: Column array with the number of cams used.
% %  - trajectories: Column array with the number of trajectories used.
% %  - kind: Kind of dictionary.
% %        - 'bow'. Bow dictionary.
% %        - 'fv'. FV dictionary.
% %  - pars: struct with fields
% %      .ftdims: vector with dimensions of each type of feature
% %      .ftsel: boolean vector with selected features
% %      .sqrt: boolean vector to compute sqrt on low-level features. Only valid if multi-dictionary
% %      .onlyct: extract only central subsequence
% %
% % Output:
% %  - histograms: Calculated histograms.
% %  - labels: Column array with labels of every histogram.
% %  - lfiles: Array with names of video files used.
% %  - id_videos: Unique id for every video file.
% %
% % See also createBOWDictionary, FV class
%
% % Versions:
% %  - 03/Apr/2014: mjmarin, added new parameters 'pars' to easily include
% %  new parameters for encoding
% %
% %  - 19/Dic/2014: mjmarin, added opt 'doDTsel' for filtering Dense Tracks
%
% if ~exist('pars', 'var')
%    pars = [];
% end
%
% if isempty(pars)
%    pars.ftdims = [];
%    pars.ftsel = 1;
%    pars.ftsqrt = [];
%    pars.onlyct = 0;
%    pars.dbname = 'casia';
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
% % % Loading static information about subjects.
% % switch lower(pars.dbname)
% %    case 'gait'
% %       avaSubjects;
% %    case 'mobo'
% %       moboSubjects;
% %    otherwise
% %       error(['Invalid dataset: ' dbname]);
% % end % switch
% % %gt_subjects = gt_subjects;
%
% %totalFeatures = mj_loadFeatPartitionsCASIA(featuresPath, partitions, cams, trajectories, sequences); % Added by mjmarin: replaces previous code
% totalFeatures = mj_loadFeatPartitionsGen(pars.dbname, featuresPath, partitions, cams, trajectories, sequences);
%
% histograms = [];
% labels = [];
% id_videos = [];
% this_vid = 0;   % Counter
% lfiles = cell(length(totalFeatures), 1); % Output filenames
% for i=1:length(totalFeatures) % Video files.
%     jlabels = [];
%     jhistograms = [];
%     jid_videos = [];
%     ilfeats = totalFeatures(i).feats;
%     nilfeats = length(ilfeats);
%     for j=1:nilfeats % Features of a video file.
%         % Find label.
% %         parts = regexp(ilfeats(j).name, '_', 'split');
% %         name = regexp(parts{1}, '-', 'split');
% %         label = str2double(name{1});
%       label = mj_gaitLabFromName(pars.dbname, ilfeats(j).name);
%
%         % Obtaining features.
% 		matfeats = fullfile(featuresPath, ilfeats(j).name);
% 		try
%            features = load(matfeats);
% 		catch
% 		   disp(['WARN: cannot read file ' matfeats]);
% 		   features.detections = [];
% 		end
%         features = features.detections;
%
%         if pars.doDTsel
%            features = mj_selectKeyDTs(features, pars.doDTsel);
%         end
%
%         % Computing new partitions.
%         if ~isempty(totalFeatures(i).moreHorizontalPartitions) || ~isempty(totalFeatures(i).moreVerticalPartitions)
%             grid.horizontal = totalFeatures(i).moreHorizontalPartitions;
%             grid.vertical = totalFeatures(i).moreVerticalPartitions;
%             params.offset = 20;
%             % Loading tracks.
%             tracks_file = fullfile(tracksPath, sprintf('%s.mat', parts{1}));
%             tracks = load(tracks_file);
%             tracks = tracks.detections;
%             array = cell(length(features), 1);
%             for feats = 1:length(features)
%                 array{feats} = fc_fitFeatures(features{feats}, tracks.tracks(1), grid, params);
%             end
%
%             features = cell(length(totalFeatures(i).moreHorizontalPartitions) * length(totalFeatures(i).moreVerticalPartitions) * length(features), 1);
%             index = 1;
%
%             % Sorting the array according to the established order.
%             for horBlocks = 0:length(array{1}) / length(totalFeatures(i).moreHorizontalPartitions)
%                 for feats = 1:length(array)
%                     for pos = 1:length(array{1}) / length(totalFeatures(i).moreHorizontalPartitions)
%                         features{index} = array{feats}{(horBlocks * (length(array{1}) / length(totalFeatures(i).moreHorizontalPartitions)) + pos)};
%                         index = index + 1;
%                     end
%                 end
%             end
%         end
%
%         if isempty(features)
%             disp(['WARN: empty data in ' lfiles{i}]);
%         else
%            this_vid = this_vid + 1; % Next id for video
%            lfiles{this_vid} = ilfeats(j).name; % Get filename
%             % Time split.
%             if totalFeatures(i).nFrames > 0
%                 lfeatures = []; % Just in case using multi-partition
%                 if length(totalFeatures(i).partition) > 1
%                    if totalFeatures(i).join
%                       for ptx = 1:length(totalFeatures(i).partition)
%                          if ptx == 1
%                             lfeatures{ptx} = mj_calculateTimePartition(features{totalFeatures(i).partition(ptx)}, totalFeatures(i).nFrames, totalFeatures(i).overlap, pars.onlyct);
%                          else
%                             lfeatures_temp = mj_calculateTimePartition(features{totalFeatures(i).partition(ptx)}, totalFeatures(i).nFrames, totalFeatures(i).overlap, pars.onlyct);
%                             if length(lfeatures_temp) == length(lfeatures{1})
%                                for i_ = 1:length(lfeatures_temp)
%                                   tmp = [lfeatures{1}{i_}, lfeatures_temp{i_}];
%                                   lfeatures{1}{i_} = tmp;
%                                end % i_
%                             end % if
%                          end % if
%                       end % ptx
%                    else % Classic mode
%                       for ptx = 1:length(totalFeatures(i).partition)
%                          lfeatures{ptx} = mj_calculateTimePartition(features{totalFeatures(i).partition(ptx)}, totalFeatures(i).nFrames, totalFeatures(i).overlap, pars.onlyct);
%                       end % ptx
%                    end % if-join
%                 else % Single partition, as done by FMCP
%                    lfeatures{1} = mj_calculateTimePartition(features{totalFeatures(i).partition}, totalFeatures(i).nFrames, totalFeatures(i).overlap, pars.onlyct);
%                 end
%
%                 jhistograms_p = [];
%                 for ptx = 1:length(lfeatures),
%                    features = lfeatures{ptx};
%                    jhistograms_ = [];
%                    for k=1:length(features) % Time parts.
%                       % Obtaining features of the desired partitions.
%                       matrix = fc_calculateFeatsMatrix(features, k);
%                       % Encode with Fisher Vector
%                       if strcmp('fv', kind)
% %                          if iscell(dictionary)
% %                             h = mj_encodeMultiDict(matrix, dictionary, pars);
% %                          else
% %                             h = dictionary.encode(matrix); % mjmarin: make sure matrix is [ndims, nsamples]
% %                          end
%                          h = mj_encodeFV(matrix, dictionary, pars);
%                          jhistograms_ = [jhistograms_ ; h'];
%                       elseif strcmp('bow', kind)
%                          % Calculating distances between feats and centroids.
%                          D = vl_alldist2(matrix, dictionary);
%                          % Calculating histograms.
%                          khistogram = zeros(1, size(dictionary, 2));
%                          for l=1:size(D, 1)
%                             [C, I] = min(D(l, :));
%                             khistogram(1, :) = vl_binsum(khistogram(1, :), 1, I(1));
%                          end
%
%                          % Normalize histograms.
%                          khistogram(1, :) = khistogram(1, :) / sum(khistogram(1, :));
%
%                          jhistograms_ = [jhistograms_ ; khistogram];
%                       end % if
%                    end % k
% 				   if ~isempty(jhistograms_p)
% 				      if size(jhistograms_p,1) == size(jhistograms_,1)
% 				         jhistograms_p = [jhistograms_p, jhistograms_];
% 					  else
% 					     disp(['Invalid sequence for concatenation: ' matfeats]);
% 						 jhistograms_p = [];
% 						 break
% 					  end
% 				   else
%                       jhistograms_p = [jhistograms_p, jhistograms_];
% 				   end % if
%                 end % ptx
%                 jhistograms = [jhistograms; jhistograms_p];
%                 jlabels = [jlabels ; label+zeros(size(jhistograms_p,1),1)];
%                 jid_videos = [jid_videos; this_vid+zeros(size(jhistograms_p,1),1)];
%             else % Take whole sequence to compute descriptor
%                 % Obtaining features of the desired partitions.
%                 matrix = fc_calculateFeatsMatrix(features, totalFeatures(i).partition);
%                 if totalFeatures(i).join
%                    matrix = cell2mat(matrix);
%                 end
%
%                 if ~isempty(matrix) % Deal with no data
%                    jlabels = [jlabels ; label];
%                    jid_videos = [jid_videos; this_vid];
%
%                    if strcmp('fv', kind)
%                       if iscell(matrix) % Several partitions
%                          h = [];
%                          for ixmt = 1:length(matrix)
%                             % Encode with Fisher Vector
% %                             if iscell(dictionary)
% %                                h_ = mj_encodeMultiDict(matrix{ixmt}, dictionary, pars);
% %                             else
% %                                h_ = dictionary.encode(matrix{ixmt}); % mjmarin: make sure matrix is [ndims, nsamples]
% %                             end
%                             h_ = mj_encodeFV(matrix{ixmt}, dictionary, pars);
%                             h = [h; h_];
%                          end
%                          jhistograms = [jhistograms ; h'];
%                       else
%                          % Encode with Fisher Vector
% %                          if iscell(dictionary)
% % %                             lms = mj_splitFeatVector(matrix', pars.ftdims); % DEVELOP!!! %lms = mj_splitFeatVector(matrix', [30 96 96 96]); % DEVELOP!!!
% % %                             h = [];
% % %                             for dix_ = 1:length(dictionary)
% % %                                if ~isscalar(pars.ftsel) && ~pars.ftsel(dix_)
% % %                                   continue
% % %                                end
% % %                                dictionary_ = dictionary{dix_};
% % %                                h_d = dictionary_.encode(lms{dix_}');
% % %                                h = [h; h_d];
% % %                             end % dix_
% %                               h = mj_encodeMultiDict(matrix, dictionary, pars);
% %                          else
% %                             h = dictionary.encode(matrix); % mjmarin: make sure matrix is [ndims, nsamples]
% %                          end
%                          h = mj_encodeFV(matrix, dictionary, pars);
%                          jhistograms = [jhistograms ; h'];
%                       end
%                    elseif strcmp('bow', kind)
%                       if iscell(matrix) % Several partitions
%                          khistogram = [];
%                          for  ixmt = 1:length(matrix)
%                             khistogram_ = singleBOWnorm(matrix{ixmt}, dictionary);
%                             khistogram = [khistogram, khistogram_];
%                          end % ixmt
%
%                          jhistograms = [jhistograms ; khistogram];
%                       else
%                          khistogram = singleBOWnorm(matrix, dictionary); % mjmarin: added function to simplify code
%                          jhistograms = [jhistograms ; khistogram];
%                       end
%                    end
%                 end % if-empty(matrix)
%             end
%         end
%     end
%
%     labels = [labels ; jlabels];
%     id_videos = [id_videos ; jid_videos];
%     histograms = [histograms ; jhistograms];
% end
%
%
% % Private functions
% % ------------------------------------------------------
% function khistogram = singleBOWnorm(matrix, dictionary)
%
% D = vl_alldist2(matrix, dictionary);
% % Calculating histograms.
% khistogram = zeros(1, size(dictionary, 2));
% for k=1:size(D, 1)
%    [C, I] = min(D(k, :));
%    khistogram(1, :) = vl_binsum(khistogram(1, :), 1, I(1));
% end
%
% % Normalize histograms.
% khistogram(1, :) = khistogram(1, :) / sum(khistogram(1, :));
