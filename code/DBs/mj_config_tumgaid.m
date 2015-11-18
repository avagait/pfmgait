function cfg = mj_config_tumgaid()
% cfg = mj_config_tumgaid()
% COMMENT ME!!!
% Parameters of dataset TUM-GAID
% Output:
%  - cfg: struct
%
% (c) MJMJ/2014

dbname = 'tum_gaid'; mj_gaitLocalPaths; basedir = labelsdir;
%basedir = '/data/mjetal/databases/TUM_GAID/labels';

train_ids = load(fullfile(basedir, 'tumgaidtrainids.lst'));
val_ids = load(fullfile(basedir, 'tumgaidvalids.lst'));
test_ids = load(fullfile(basedir, 'tumgaidtestids.lst'));
 
temporal_train_ids = train_ids(train_ids <= 32);
temporal_val_ids = val_ids(val_ids <= 32);
temporal_test_ids = test_ids(test_ids <= 32);


%% Experiment 1
experiments(1).training = train_ids; %[1:100];
experiments(1).validation = val_ids; %[101:150];
experiments(1).test = test_ids; %[151:305];
experiments(1).seqs_trn = [1:4];
experiments(1).seqs_tst = [5:6];
experiments(1).trjs_trn = {'n'};
experiments(1).trjs_tst = {'n'};
experiments(1).rootdirfix = '';


%% Experiment 2
experiments(2).training = train_ids; %[1:100];
experiments(2).validation = val_ids; %[101:150];
experiments(2).test = test_ids; %[151:305];
experiments(2).seqs_trn = [1:4];
experiments(2).seqs_tst = [1:2];
experiments(2).trjs_trn = {'n'};
experiments(2).trjs_tst = {'b'};
experiments(2).rootdirfix = '';

%% Experiment 3
experiments(3).training = train_ids; %[1:100];
experiments(3).validation = val_ids; %[101:150];
experiments(3).test = test_ids; %[151:305];
experiments(3).seqs_trn = [1:4];
experiments(3).seqs_tst = [1:2];
experiments(3).trjs_trn = {'n'};
experiments(3).trjs_tst = {'s'};
experiments(3).rootdirfix = '';

%% Experiment 4
experiments(4).training = temporal_train_ids;
experiments(4).validation = temporal_val_ids;
experiments(4).test = temporal_test_ids;
experiments(4).seqs_trn = [1:4];
experiments(4).seqs_tst = [11:12];
experiments(4).trjs_trn = {'n'};
experiments(4).trjs_tst = {'n'};
experiments(4).rootdirfix = '16';


%% Experiment 5
experiments(5).training = temporal_train_ids;
experiments(5).validation = temporal_val_ids;
experiments(5).test = temporal_test_ids;
experiments(5).seqs_trn = [1:4];
experiments(5).seqs_tst = [3:4];
experiments(5).trjs_trn = {'n'};
experiments(5).trjs_tst = {'b'};
experiments(5).rootdirfix = '16';


%% Experiment 6
experiments(6).training = temporal_train_ids;
experiments(6).validation = temporal_val_ids;
experiments(6).test = temporal_test_ids;
experiments(6).seqs_trn = [1:4];
experiments(6).seqs_tst = [3:4];
experiments(6).trjs_trn = {'n'};
experiments(6).trjs_tst = {'s'};
experiments(6).rootdirfix = '16';

%% Experiment 9
experiments(9).training = test_ids; % Training on test subjects
experiments(9).validation = val_ids; %
experiments(9).test = test_ids; %
experiments(9).seqs_trn = [1:4];
experiments(9).seqs_tst = [1:2];
experiments(9).trjs_trn = {'n'};
experiments(9).trjs_tst = {'s'};
experiments(9).rootdirfix = 'tt';

%% Experiment 8
experiments(8).training = [train_ids ; val_ids]; %[1:100];
experiments(8).validation = val_ids; %[101:150];
experiments(8).test = test_ids; %[151:305];
experiments(8).seqs_trn = [1:4];
experiments(8).seqs_tst = [1:2];
experiments(8).trjs_trn = {'n'};
experiments(8).trjs_tst = {'n'};
experiments(8).rootdirfix = '150';

%% Experiment DEVEL
experiments(20).training = [1:9]; % 
experiments(20).validation = val_ids; %
experiments(20).test = [1:9]; %
experiments(20).seqs_trn = [1:2];
experiments(20).seqs_tst = [11:12];
experiments(20).trjs_trn = {'n'};
experiments(20).trjs_tst = {'n'};
experiments(20).rootdirfix = 'Dev';


%% Experiment 10
experiments(10).training = train_ids; %[1:100];
experiments(10).validation = val_ids; %[101:150];
experiments(10).test = train_ids; %[151:305];
experiments(10).seqs_trn = [1:4];
experiments(10).seqs_tst = [5:6];
experiments(10).trjs_trn = {'n'};
experiments(10).trjs_tst = {'n'};
experiments(10).rootdirfix = '100';


%% Experiment 10
experiments(11).training = train_ids; %[1:100];
experiments(11).validation = val_ids; %[101:150];
experiments(11).test = test_ids; %[151:305];
experiments(11).seqs_trn = [1:4];
experiments(11).seqs_tst = [1:4];
experiments(11).trjs_trn = {'n'};
experiments(11).trjs_tst = {'n'};
experiments(11).rootdirfix = '';


%% Experiment 1
experiments(101).training = train_ids; %[1:100];
experiments(101).validation = val_ids; %[101:150];
experiments(101).test = test_ids; %[151:305];
experiments(101).seqs_trn = [1:4];
experiments(101).seqs_tst = [5:6];
experiments(101).trjs_trn = {'n'};
experiments(101).trjs_tst = {'n'};
experiments(101).rootdirfix = 'fvK';


%% Experiment 2
experiments(102).training = train_ids; %[1:100];
experiments(102).validation = val_ids; %[101:150];
experiments(102).test = test_ids; %[151:305];
experiments(102).seqs_trn = [1:4];
experiments(102).seqs_tst = [1:2];
experiments(102).trjs_trn = {'n'};
experiments(102).trjs_tst = {'b'};
experiments(102).rootdirfix = 'fvK';

%% Experiment 3
experiments(103).training = train_ids; %[1:100];
experiments(103).validation = val_ids; %[101:150];
experiments(103).test = test_ids; %[151:305];
experiments(103).seqs_trn = [1:4];
experiments(103).seqs_tst = [1:2];
experiments(103).trjs_trn = {'n'};
experiments(103).trjs_tst = {'s'};
experiments(103).rootdirfix = 'fvK';


%% Experiment 4
experiments(104).training = temporal_train_ids;
experiments(104).validation = temporal_val_ids;
experiments(104).test = temporal_test_ids;
experiments(104).seqs_trn = [1:4];
experiments(104).seqs_tst = [11:12];
experiments(104).trjs_trn = {'n'};
experiments(104).trjs_tst = {'n'};
experiments(104).rootdirfix = 'fvK16C';


%% Experiment 5
experiments(105).training = temporal_train_ids;
experiments(105).validation = temporal_val_ids;
experiments(105).test = temporal_test_ids;
experiments(105).seqs_trn = [1:4];
experiments(105).seqs_tst = [3:4];
experiments(105).trjs_trn = {'n'};
experiments(105).trjs_tst = {'b'};
experiments(105).rootdirfix = 'fvK16C';


%% Experiment 5
experiments(106).training = temporal_train_ids;
experiments(106).validation = temporal_val_ids;
experiments(106).test = temporal_test_ids;
experiments(106).seqs_trn = [1:4];
experiments(106).seqs_tst = [3:4];
experiments(106).trjs_trn = {'n'};
experiments(106).trjs_tst = {'s'};
experiments(106).rootdirfix = 'fvK16C';


%% Experiment 6
experiments(107).training = temporal_train_ids;
experiments(107).validation = temporal_val_ids;
experiments(107).test = [temporal_train_ids ; temporal_val_ids];
experiments(107).seqs_trn = [1:4];
experiments(107).seqs_tst = [11:12];
experiments(107).trjs_trn = {'n'};
experiments(107).trjs_tst = {'n'};
experiments(107).rootdirfix = 'fvK16COOS';


%% Experiment 6
experiments(108).training = temporal_train_ids;
experiments(108).validation = temporal_val_ids;
experiments(108).test = [temporal_train_ids ; temporal_val_ids];
experiments(108).seqs_trn = [1:4]; 
experiments(108).seqs_tst = [4];%[3:4];
experiments(108).trjs_trn = {'n'};
experiments(108).trjs_tst = {'b'};
experiments(108).rootdirfix = 'fvK16COOS';


%% Experiment 6
experiments(109).training = temporal_train_ids;
experiments(109).validation = temporal_val_ids;
experiments(109).test = [temporal_train_ids ; temporal_val_ids];
experiments(109).seqs_trn = [1:4]; 
experiments(109).seqs_tst = [4];%[3:4];
experiments(109).trjs_trn = {'n'};
experiments(109).trjs_tst = {'s'};
experiments(109).rootdirfix = 'fvK16COOS';

%% Experiment 6
experiments(110).training = train_ids;
experiments(110).validation = val_ids;
experiments(110).test = test_ids;
experiments(110).seqs_trn = [1:4];
experiments(110).seqs_tst = [6];%[3:4];
experiments(110).trjs_trn = {'n'};
experiments(110).trjs_tst = {'n'};
experiments(110).rootdirfix = 'fvCOOS';


%% Experiment 4
experiments(114).training = temporal_train_ids;
experiments(114).validation = temporal_val_ids;
experiments(114).test = temporal_test_ids;
experiments(114).seqs_trn = [1:4];
experiments(114).seqs_tst = [11:12];
experiments(114).trjs_trn = {'n'};
experiments(114).trjs_tst = {'n'};
experiments(114).rootdirfix = 'fvK16HOG';


%% Experiment 5
experiments(115).training = temporal_train_ids;
experiments(115).validation = temporal_val_ids;
experiments(115).test = temporal_test_ids;
experiments(115).seqs_trn = [1:4];
experiments(115).seqs_tst = [3:4];
experiments(115).trjs_trn = {'n'};
experiments(115).trjs_tst = {'b'};
experiments(115).rootdirfix = 'fvK16HOG';


%% Experiment 5
experiments(116).training = temporal_train_ids;
experiments(116).validation = temporal_val_ids;
experiments(116).test = temporal_test_ids;
experiments(116).seqs_trn = [1:4];
experiments(116).seqs_tst = [3:4];
experiments(116).trjs_trn = {'n'};
experiments(116).trjs_tst = {'s'};
experiments(116).rootdirfix = 'fvK16HOG';


%% Experiment 1
experiments(301).training = train_ids; %[1:100];
experiments(301).validation = val_ids; %[101:150];
experiments(301).test = test_ids; %[151:305];
experiments(301).seqs_trn = [1:4];
experiments(301).seqs_tst = [5:6];
experiments(301).trjs_trn = {'n'};
experiments(301).trjs_tst = {'n'};
experiments(301).rootdirfix = 'TB';


%% Experiment 4
experiments(304).training = temporal_train_ids;
experiments(304).validation = temporal_val_ids;
experiments(304).test = temporal_test_ids;
experiments(304).seqs_trn = [1:4];
experiments(304).seqs_tst = [11:12];
experiments(304).trjs_trn = {'n'};
experiments(304).trjs_tst = {'n'};
experiments(304).rootdirfix = 'TBT';

%% Experiment 4
experiments(404).training = temporal_train_ids;
experiments(404).validation = temporal_val_ids;
experiments(404).test = temporal_test_ids;
experiments(404).seqs_trn = [1:4];
experiments(404).seqs_tst = [11:12];
experiments(404).trjs_trn = {'n'};
experiments(404).trjs_tst = {'n'};
experiments(404).rootdirfix = 'ABRS';


experiments(405).training = temporal_train_ids;
experiments(405).validation = temporal_val_ids;
experiments(405).test = temporal_test_ids;
experiments(405).seqs_trn = [1:4];
experiments(405).seqs_tst = [3:4];
experiments(405).trjs_trn = {'n'};
experiments(405).trjs_tst = {'b'};
experiments(405).rootdirfix = 'ABRS';


%% Experiment 5
experiments(406).training = temporal_train_ids;
experiments(406).validation = temporal_val_ids;
experiments(406).test = temporal_test_ids;
experiments(406).seqs_trn = [1:4];
experiments(406).seqs_tst = [3:4];
experiments(406).trjs_trn = {'n'};
experiments(406).trjs_tst = {'s'};
experiments(406).rootdirfix = 'ABRS';

%% Experiment 1
experiments(1001).training = train_ids; %[1:100];
experiments(1001).validation = val_ids; %[101:150];
experiments(1001).test = test_ids; %[151:305];
experiments(1001).seqs_trn = [1:6];
experiments(1001).seqs_tst = [1:6];
experiments(1001).trjs_trn = {'n'};
experiments(1001).trjs_tst = {'n'};
experiments(1001).rootdirfix = 'Gender';


%% Experiment 2
experiments(1002).training = train_ids; %[1:100];
experiments(1002).validation = val_ids; %[101:150];
experiments(1002).test = test_ids; %[151:305];
experiments(1002).seqs_trn = [1:6];
experiments(1002).seqs_tst = [1:2];
experiments(1002).trjs_trn = {'n'};
experiments(1002).trjs_tst = {'b'};
experiments(1002).rootdirfix = 'Gender';

%% Experiment 3
experiments(1003).training = train_ids; %[1:100];
experiments(1003).validation = val_ids; %[101:150];
experiments(1003).test = test_ids; %[151:305];
experiments(1003).seqs_trn = [1:6];
experiments(1003).seqs_tst = [1:2];
experiments(1003).trjs_trn = {'n'};
experiments(1003).trjs_tst = {'s'};
experiments(1003).rootdirfix = 'Gender';

%% Experiment 4
experiments(1004).training = train_ids;
experiments(1004).validation = val_ids;
experiments(1004).test = test_ids;
experiments(1004).seqs_trn = [1:6];
experiments(1004).seqs_tst = [1:6];
experiments(1004).trjs_trn = {'n'};
experiments(1004).trjs_tst = {'n'};
experiments(1004).rootdirfix = 'Shoes';


%% Experiment 5
experiments(1005).training = train_ids;
experiments(1005).validation = val_ids;
experiments(1005).test = test_ids;
experiments(1005).seqs_trn = [1:6];
experiments(1005).seqs_tst = [1:2];
experiments(1005).trjs_trn = {'n'};
experiments(1005).trjs_tst = {'b'};
experiments(1005).rootdirfix = 'Shoes';


%% Experiment 6
experiments(1006).training = train_ids;
experiments(1006).validation = val_ids;
experiments(1006).test = test_ids;
experiments(1006).seqs_trn = [1:6];
experiments(1006).seqs_tst = [1:2];
experiments(1006).trjs_trn = {'n'};
experiments(1006).trjs_tst = {'s'};
experiments(1006).rootdirfix = 'Shoes';

%% Experiment 1
experiments(1011).training = train_ids; %[1:100];
experiments(1011).validation = val_ids; %[101:150];
experiments(1011).test = test_ids; %[151:305];
experiments(1011).seqs_trn = [1:4];
experiments(1011).seqs_tst = [5:6];
experiments(1011).trjs_trn = {'n'};
experiments(1011).trjs_tst = {'n'};
experiments(1011).rootdirfix = 'Depth';


%% Experiment 2
experiments(1012).training = train_ids; %[1:100];
experiments(1012).validation = val_ids; %[101:150];
experiments(1012).test = test_ids; %[151:305];
experiments(1012).seqs_trn = [1:4];
experiments(1012).seqs_tst = [1:2];
experiments(1012).trjs_trn = {'n'};
experiments(1012).trjs_tst = {'b'};
experiments(1012).rootdirfix = 'Depth';

%% Experiment 3
experiments(1013).training = train_ids; %[1:100];
experiments(1013).validation = val_ids; %[101:150];
experiments(1013).test = test_ids; %[151:305];
experiments(1013).seqs_trn = [1:4];
experiments(1013).seqs_tst = [1:2];
experiments(1013).trjs_trn = {'n'};
experiments(1013).trjs_tst = {'s'};
experiments(1013).rootdirfix = 'Depth';

%% Experiment 4
experiments(1014).training = temporal_train_ids;
experiments(1014).validation = temporal_val_ids;
experiments(1014).test = temporal_test_ids;
experiments(1014).seqs_trn = [1:4];
experiments(1014).seqs_tst = [11:12];
experiments(1014).trjs_trn = {'n'};
experiments(1014).trjs_tst = {'n'};
experiments(1014).rootdirfix = '16Depth';


%% Experiment 5
experiments(1015).training = temporal_train_ids;
experiments(1015).validation = temporal_val_ids;
experiments(1015).test = temporal_test_ids;
experiments(1015).seqs_trn = [1:4];
experiments(1015).seqs_tst = [3:4];
experiments(1015).trjs_trn = {'n'};
experiments(1015).trjs_tst = {'b'};
experiments(1015).rootdirfix = '16Depth';


%% Experiment 6
experiments(1016).training = temporal_train_ids;
experiments(1016).validation = temporal_val_ids;
experiments(1016).test = temporal_test_ids;
experiments(1016).seqs_trn = [1:4];
experiments(1016).seqs_tst = [3:4];
experiments(1016).trjs_trn = {'n'};
experiments(1016).trjs_tst = {'s'};
experiments(1016).rootdirfix = '16Depth';

%% Experiment 1
experiments(1021).training = train_ids; %[1:100];
experiments(1021).validation = val_ids; %[101:150];
experiments(1021).test = test_ids; %[151:305];
experiments(1021).seqs_trn = [1:6];
experiments(1021).seqs_tst = [1:6];
experiments(1021).trjs_trn = {'n'};
experiments(1021).trjs_tst = {'n'};
experiments(1021).rootdirfix = 'GenderDepth';


%% Experiment 2
experiments(1022).training = train_ids; %[1:100];
experiments(1022).validation = val_ids; %[101:150];
experiments(1022).test = test_ids; %[151:305];
experiments(1022).seqs_trn = [1:6];
experiments(1022).seqs_tst = [1:2];
experiments(1022).trjs_trn = {'n'};
experiments(1022).trjs_tst = {'b'};
experiments(1022).rootdirfix = 'GenderDepth';

%% Experiment 3
experiments(1023).training = train_ids; %[1:100];
experiments(1023).validation = val_ids; %[101:150];
experiments(1023).test = test_ids; %[151:305];
experiments(1023).seqs_trn = [1:6];
experiments(1023).seqs_tst = [1:2];
experiments(1023).trjs_trn = {'n'};
experiments(1023).trjs_tst = {'s'};
experiments(1023).rootdirfix = 'GenderDepth';

%% Experiment 4
experiments(1024).training = train_ids;
experiments(1024).validation = val_ids;
experiments(1024).test = test_ids;
experiments(1024).seqs_trn = [1:6];
experiments(1024).seqs_tst = [1:6];
experiments(1024).trjs_trn = {'n'};
experiments(1024).trjs_tst = {'n'};
experiments(1024).rootdirfix = 'ShoesDepth';


%% Experiment 5
experiments(1025).training = train_ids;
experiments(1025).validation = val_ids;
experiments(1025).test = test_ids;
experiments(1025).seqs_trn = [1:6];
experiments(1025).seqs_tst = [1:2];
experiments(1025).trjs_trn = {'n'};
experiments(1025).trjs_tst = {'b'};
experiments(1025).rootdirfix = 'ShoesDepth';


%% Experiment 6
experiments(1026).training = train_ids;
experiments(1026).validation = val_ids;
experiments(1026).test = test_ids;
experiments(1026).seqs_trn = [1:6];
experiments(1026).seqs_tst = [1:2];
experiments(1026).trjs_trn = {'n'};
experiments(1026).trjs_tst = {'s'};
experiments(1026).rootdirfix = 'ShoesDepth';


%% Experiment SVM Shoes
experiments(1124).training = train_ids;
experiments(1124).validation = val_ids;
experiments(1124).test = train_ids;
experiments(1124).seqs_trn = [1:4];
experiments(1124).seqs_tst = [5:6];
experiments(1124).trjs_trn = {'n'};
experiments(1124).trjs_tst = {'n'};
experiments(1124).rootdirfix = 'ShoesSVMDepth';

%% Experiment SVM Shoes
experiments(1125).training = train_ids;
experiments(1125).validation = val_ids;
experiments(1125).test = train_ids;
experiments(1125).seqs_trn = [1:4];
experiments(1125).seqs_tst = [5:6];
experiments(1125).trjs_trn = {'n'};
experiments(1125).trjs_tst = {'n'};
experiments(1125).rootdirfix = 'GenderSVMDepth';

%% Experiment 1
experiments(1201).training = train_ids; %[1:100];
experiments(1201).validation = val_ids; %[101:150];
experiments(1201).test = test_ids; %[151:305];
experiments(1201).seqs_trn = [1:6];
experiments(1201).seqs_tst = [1:6];
experiments(1201).trjs_trn = {'n'};
experiments(1201).trjs_tst = {'n'};
experiments(1201).rootdirfix = 'ShoesEarlyFusion';%'GenderEarlyFusion';


%% Experiment 1
experiments(2001).training = train_ids; %[1:100];
experiments(2001).validation = val_ids; %[101:150];
experiments(2001).test = test_ids; %[151:305];
experiments(2001).seqs_trn = [1:4];
experiments(2001).seqs_tst = [5:6];
experiments(2001).trjs_trn = {'n'};
experiments(2001).trjs_tst = {'n'};
experiments(2001).rootdirfix = '80x60';

%% Experiment 2
experiments(2002).training = train_ids; %[1:100];
experiments(2002).validation = val_ids; %[101:150];
experiments(2002).test = test_ids; %[151:305];
experiments(2002).seqs_trn = [1:4];
experiments(2002).seqs_tst = [1:2];
experiments(2002).trjs_trn = {'n'};
experiments(2002).trjs_tst = {'b'};
experiments(2002).rootdirfix = '80x60';

%% Experiment 3
experiments(2003).training = train_ids; %[1:100];
experiments(2003).validation = val_ids; %[101:150];
experiments(2003).test = test_ids; %[151:305];
experiments(2003).seqs_trn = [1:4];
experiments(2003).seqs_tst = [1:2];
experiments(2003).trjs_trn = {'n'};
experiments(2003).trjs_tst = {'s'};
experiments(2003).rootdirfix = '80x60';

%% Cameras (common for all experiments)
[experiments.cams_trn] = deal([]);
[experiments.cams_tst] = deal([]);

%% Output
cfg.dbname = 'tum_gaid';
cfg.trjs = {'n','b','s'};
cfg.experiments = experiments;


