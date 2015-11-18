function cfg = mj_config_casiac()
% cfg = mj_config_casiac()
% COMMENT ME!!!
% Parameters of dataset CASIA-C
% Output:
%  - cfg: struct
%
% (c) MJMJ/2014


%% Experiment 1
experiments(1).training = 'all';
experiments(1).validation = [];
experiments(1).test = 'all';
experiments(1).seqs_trn = [0:1];
experiments(1).seqs_tst = [2:3];
experiments(1).trjs_trn = {'fn'};
experiments(1).trjs_tst = {'fn'};

%% Experiment 2
experiments(2).training = 'all';
experiments(2).validation = [];
experiments(2).test = 'all';
experiments(2).seqs_trn = [0:1];
experiments(2).seqs_tst = [0:1];
experiments(2).trjs_trn = {'fn'};
experiments(2).trjs_tst = {'fs'};

%% Experiment 3
experiments(3).training = 'all';
experiments(3).validation = [];
experiments(3).test = 'all';
experiments(3).seqs_trn = [0:1];
experiments(3).seqs_tst = [0:1];
experiments(3).trjs_trn = {'fn'};
experiments(3).trjs_tst = {'fq'};

%% Experiment 4
experiments(4).training = 'all';
experiments(4).validation = [];
experiments(4).test = 'all';
experiments(4).seqs_trn = [0:1];
experiments(4).seqs_tst = [0:1];
experiments(4).trjs_trn = {'fn'};
experiments(4).trjs_tst = {'fb'};

%% Cameras (common for all experiments)
[experiments.cams_trn] = deal([90]);
[experiments.cams_tst] = deal([90]);

%% Output
cfg.dbname = 'casiac';
cfg.trjs = {'fn','fs','fq','fb'};
cfg.experiments = experiments;


