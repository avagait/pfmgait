function bool = isUCOpc()
% bool = isUCOpc()
% COMMENT ME!!!
%
% (c) MJMJ/2014

[ret, name] = system('hostname'); 

name = strtrim(lower(name));

bool = strcmp(name, 'sylarucopc');
