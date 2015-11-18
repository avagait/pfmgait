function totalFeatures = mj_loadFeatPartitionsGen(dbname, featuresPath, partitions, cams, trajectories, sequences, pars)
% totalFeatures = mj_loadFeatPartitionsGen(dbname, featuresPath, partitions, cams, trajectories, sequences, pars)
% COMMENT ME!!!
%
%
% (c) MJMJ/2014

if ~exist('pars', 'var')
    pars = [];
end

if isempty(pars)
    pars.subjects = 'all';
end

%% Main
totalFeatures = [];

switch lower(dbname)
    case {'ava', 'mobo'}
        totalFeatures = mj_loadFeatPartitions(featuresPath, partitions, cams, trajectories, sequences);
    case {'casia', 'casiab', 'casiac'}
        totalFeatures = mj_loadFeatPartitionsCASIA(featuresPath, partitions, cams, trajectories, sequences);
    case {'tum', 'tum_gaid', 'tum_gaid_depth', 'tum_gaid_gender'}
        totalFeatures = mj_loadFeatPartitionsTUM(featuresPath, partitions, trajectories, sequences);
    case {'tum_audio', 'tum_gaid_audio', 'tum_gaid_audio_gender'}
        totalFeatures = mj_loadFeatPartitionsTUMAudio(featuresPath, partitions, trajectories, sequences);
    case {'ky4d'}
        totalFeatures = mj_loadFeatPartitionsKY4D(featuresPath, partitions, cams, trajectories, sequences);
        
    otherwise
        disp(['WARN: unrecognized dataset ' dbname]);
end

%% Post-processing
if ~ischar(pars.subjects) % Not 'all'
    subjects = pars.subjects;
    
    %lIds = zeros(size(totalFeatures));
    for i=1:length(totalFeatures)
        ids = zeros(size(totalFeatures(i).feats));
        for j=1:length(totalFeatures(i).feats)
            % Loading dense_feats of the given part.
            if strcmp(dbname, 'tum_gaid_gender')
                dbname = 'tum_gaid';
            end
            if strcmp(dbname, 'tum_gaid_audio_gender')
                dbname = 'tum_gaid_audio';
            end
            label = mj_gaitLabFromName(dbname, totalFeatures(i).feats(j).name);
            
            if ismember(label, subjects) % Keep it
                ids(j) = 1;
            end
            
        end
        totalFeatures(i).feats = totalFeatures(i).feats(ids > 0);
        %if any(ids)
        %   lIds(i) = 1;
        %end
    end
    
    % Purge
    %totalFeatures = totalFeatures(lIds > 0);
end

%% Post-processing
%if ~ischar(pars.subjects) % Not 'all'
%   subjects = pars.subjects;
%
%   lIds = zeros(size(totalFeatures));
%   for i=1:length(totalFeatures)
%      ids = zeros(size(totalFeatures(i).feats));
%      for j=1:length(totalFeatures(i).feats)
%         % Loading dense_feats of the given part.
%         label = mj_gaitLabFromName(dbname, totalFeatures(i).feats(j).name);
%
%         if ismember(label, subjects) % Keep it
%            ids(j) = 1;
%         end
%
%      end
%      if any(ids)
%         lIds(i) = 1;
%      end
%   end
%
%   % Purge
%   totalFeatures = totalFeatures(lIds > 0);
%end
