% File: demopipeline.m
% Full pipeline for gait identification based on PFM descriptors
%
% See Castro et al., ICPR'2014
%
% (c) MJMJ/2016

disp('** This demo shows how to extract a global gait descriptor and classify it from a video sequence **');

if ~exist('vl_version', 'file')
   error('Please, run "vl_setup" before calling this demo.');
end

%% People detection
demodetect;

%% People tracking
demotracking;

%% Tracklets computation
demoExtractDT;

%% Traclets filtering
demoFilterDT;

%% Compute PFM descriptor
demopfm;