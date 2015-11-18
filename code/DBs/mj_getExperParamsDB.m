function cfg = mj_getExperParamsDB(dbname)
% cfg = mj_getExperParamsDB(dbname)
% COMMENT ME!!!
%
% (c) MJMJ/2014

cfg = [];

switch lower(dbname)
    case {'ava'}
        cfg = mj_config_ava();
    case 'mobo'
        cfg = mj_config_mobo();
    case {'casiab'}
        cfg = mj_config_casiab();
    case {'casiac'}
        cfg = mj_config_casiac();
    case {'tum', 'tum_gaid', 'tum_gaid_audio', 'tum_gaid_gender', 'tum_gaid_audio_gender'}
        cfg = mj_config_tumgaid();
    case {'ky4d'}
        cfg = mj_config_ky4d();
        
    otherwise
        disp(['WARN: unrecognized dataset ' dbname]);
end