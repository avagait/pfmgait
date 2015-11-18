function cfg = mj_config_casiab()
% cfg = mj_config_casiab()
% COMMENT ME!!!
% Parameters of dataset CASIA-B
% Output:
%  - cfg: struct
%
% (c) MJMJ/2014

%% Experiment 1
experiments(1).training = 'all';
experiments(1).validation = [];
experiments(1).test = 'all';
experiments(1).seqs_trn = [1:4];
experiments(1).seqs_tst = [5:6];
experiments(1).trjs_trn = {'nm'};
experiments(1).trjs_tst = {'nm'};

%% Experiment 2
experiments(2).training = 'all';
experiments(2).validation = [];
experiments(2).test = 'all';
experiments(2).seqs_trn = [1:4];
experiments(2).seqs_tst = [1:2];
experiments(2).trjs_trn = {'nm'};
experiments(2).trjs_tst = {'cl'};


%% Experiment 3
experiments(3).training = 'all';
experiments(3).validation = [];
experiments(3).test = 'all';
experiments(3).seqs_trn = [1:4];
experiments(3).seqs_tst = [1:2];
experiments(3).trjs_trn = {'nm'};
experiments(3).trjs_tst = {'bg'};

%% Cameras (common for all experiments)
[experiments.cams_trn] = deal([90]);
[experiments.cams_tst] = deal([90]);

%% Output
cfg.dbname = 'casiab';
cfg.trjs = {'nm','bg','cl'};
cfg.experiments = experiments;


