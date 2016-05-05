% File: mj_gaitLocalPaths.m
%
% Output:
%   - experdir
%
%
% (c) MJMJ/2014

if ~exist('useOldDirs', 'var')
    useOldDirs = false;
end

if ~exist('useSilh', 'var')
    useSilh = false;
end

isYuca = strcmp(getComputerName, 'yuca');
isAVA22 = strcmp(getComputerName, 'reininf22');

switch lower(dbname)
    %% CASIA
    case {'casia', 'casiab'}
        if isunix
            if useOldDirs
                experdir = '/data/experiments/casiaB/silhouettes/';
            else
                experdir = '/data/mjetal/experiments/casiaB/';
            end
        else
            if ~isUCOpc
                experdir = 'D:\experiments\casiaB\';
            else
                experdir = 'D:\experiments\casiaB\';
            end
        end
        
        if useSilh
            experdir = fullfile(experdir, 'silhouettes');
        end
        
    case {'casiac'}
        if isunix
            if useOldDirs
                experdir = '/data/experiments/casiaC/';
            else
                experdir = '/data/mjetal/experiments/casiaC/';
            end
        else
            if ~isUCOpc
                experdir = 'D:\experiments\casiaC\';
            else
                experdir = 'D:\experiments\casiaC\';
            end
        end
        
        %% TUM-GAIT
    case {'tum', 'tum_gaid', 'tum_gaid_audio', 'tum_gaid_depth', 'tum_gaid_gender', 'tum_gaid_audio_gender', 'tum_gaid_shoes'}
        if ispc
            experdir = '.\data';
            labelsdir = '.\data';
        elseif isYuca
            experdir = '/home/GAIT/experiments/TUM_GAID/';
            labelsdir = '/home/GAIT/databases/TUM_GAID/labels/';
        elseif isAVA22
            experdir = '/data_new/mjetal/experiments/TUM_GAID/';
            labelsdir = '/data_new/mjetal/databases/TUM_GAID/labels/';           
        else
            experdir = './data';
            labelsdir = '.data'; 
        end
        
    case {'ky4d'}
%         if ispc
%             experdir = 'D:\experiments\TUM_GAID';
%             labelsdir = 'D:\databases\TUM_GAID\labels';
%         else
            experdir = '/data_new/i52lofed/KY4D_color/pfm/';
%         end
        
    otherwise
        error(['Unrecognized dbname: ' dbname]);
end
