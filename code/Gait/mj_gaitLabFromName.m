function label = mj_gaitLabFromName(dbname, filename, labels)
% label = mj_gaitLabFromName(dbname, filename)
% COMMENT ME!!!
% Extract label number for this subject
%
%
%
% (c) MJMJ/2014

label = 0;

switch lower(dbname)
    case {'ava', 'avamvg'}
        avaSubjects;
        parts = regexp(filename, '_', 'split');
        idx = strcmp(parts{1}, gt_subjects);
        label = find(idx);
        if isempty(label)
            label = 0;
        end
        
    case 'mobo'
        moboSubjects;
        parts = regexp(filename, '_', 'split');
        idx = strcmp(parts{1}, gt_subjects);
        label = find(idx);
        if isempty(label)
            label = 0;
        end
        
    case {'casia', 'casiab', 'casiac'}
        parts = regexp(filename, '_', 'split');
        name = regexp(parts{1}, '-', 'split');
        label = str2double(name{1});
        
    case {'tum', 'tum_gaid', 'tum_gaid_depth'}
        parts = regexp(filename, '_', 'split');
        name = regexp(parts{1}, '-', 'split');
        id = regexp(name{1}, '\d+', 'match');
        label = str2double(id{1});
        
    case {'tum_gender', 'tum_gaid_gender'}
        parts = regexp(filename, '_', 'split');
        name = regexp(parts{1}, '-', 'split');
        id = regexp(name{1}, '\d+', 'match');
        label = str2double(id{1});
        label = labels(label);
        
    case {'tum_audio', 'tum_gaid_audio'}
        parts = regexp(filename, '_', 'split');
        label = str2double(parts{1}(2:end));

    case {'tum_audio_gender', 'tum_gaid_audio_gender'}
        parts = regexp(filename, '_', 'split');
        label = str2double(parts{1}(2:end));
        label = labels(label);
        
    case {'ky4d'}
        ky4dSubjects;
        parts = regexp(filename, '_', 'split');
        parts = regexp(parts{1}, '-', 'split');
        idx = strcmp(parts{1}, gt_subjects);
        label = find(idx);
        if isempty(label)
            label = 0;
        end
    otherwise
        error(['Invalid dataset: ' dbname]);
end
