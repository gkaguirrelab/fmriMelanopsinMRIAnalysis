%% Set parameters common to all analyses
params0.reconall         = 0;
params0.despike          = 1;
params0.slicetiming      = 0;
params0.topup            = 1;
params0.refvol           = 1;
params0.regFirst         = 1;
params0.filtType         = 'high';
params0.lowHz            = 0.01;
params0.highHz           = 0.10;
params0.physio           = 1;
params0.motion           = 1;
params0.task             = 0;
params0.localWM          = 1;
params0.anat             = 1;
params0.amem             = 20;
params0.fmem             = 50;

%% HERO_asb1 - 032416 - MaxMel400%
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_asb1/032416';
params.subjectName      = 'HERO_asb1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = fullfile('/data/jag/MELA/MelanopsinMR/LOGS/', datestr(now, 'mmddyy'));
params.jobName          = params.subjectName;
params.numRuns          = 11; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_asb1 - 040716 - MaxLMS400%
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_asb1/040716';
params.subjectName      = 'HERO_asb1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = fullfile('/data/jag/MELA/MelanopsinMR/LOGS/', datestr(now, 'mmddyy'));
params.jobName          = params.subjectName;
params.numRuns          = 10; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_aso1 - 032516 - MaxMel400%
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_aso1/032516';
params.subjectName      = 'HERO_aso1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = fullfile('/data/jag/MELA/MelanopsinMR/LOGS/', datestr(now, 'mmddyy'));
params.jobName          = params.subjectName;
params.numRuns          = 11; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_aso1 - 033016 - MaxLMS400%
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_aso1/033016';
params.subjectName      = 'HERO_aso1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = fullfile('/data/jag/MELA/MelanopsinMR/LOGS/', datestr(now, 'mmddyy'));
params.jobName          = params.subjectName;
params.numRuns          = 12; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_gka1 - 033116 - MaxMel400%
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_gka1/033116';
params.subjectName      = 'HERO_gka1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = fullfile('/data/jag/MELA/MelanopsinMR/LOGS/', datestr(now, 'mmddyy'));
params.jobName          = params.subjectName;
params.numRuns          = 12; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_gka1 - 040116 - MaxLMS400%
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_gka1/040116';
params.subjectName      = 'HERO_gka1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = fullfile('/data/jag/MELA/MelanopsinMR/LOGS/', datestr(now, 'mmddyy'));
params.jobName          = params.subjectName;
params.numRuns          = 12; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_mxs1 - 040616 - MaxMel400%
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_mxs1/040616';
params.subjectName      = 'HERO_mxs1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = fullfile('/data/jag/MELA/MelanopsinMR/LOGS/', datestr(now, 'mmddyy'));
params.jobName          = params.subjectName;
params.numRuns          = 12; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_mxs1 - 040816 - MaxLMS400%
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_mxs1/040816';
params.subjectName      = 'HERO_mxs1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = fullfile('/data/jag/MELA/MelanopsinMR/LOGS/', datestr(now, 'mmddyy'));
params.jobName          = params.subjectName;
params.numRuns          = 12; % Number of BOLD runs
create_preprocessing_scripts(params);