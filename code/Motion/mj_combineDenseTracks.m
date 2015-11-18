function [DT, lIds] = mj_combineDenseTracks(DT1, DT2)
% [DT, lIds] = mj_combineDenseTracks(DT1, DT2)
%
% COMMENT ME!!!
%
% (c) MJMJ/2014

n1 = length(DT1);
n2 = length(DT2);

DT = [DT1, DT2];

[ofrix, oix] = sort([DT.frix]);

DT = [DT(oix)];

%% Prepare indeces
lIds = cell(1,2);
lIds{1} = [1:n1];
lIds{2} = [n1+1:n1+n2];