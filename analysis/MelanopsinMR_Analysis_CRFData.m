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

%% HERO_asb1 - 060716 - MaxMelCRF
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_asb1/060716';
params.subjectName      = 'HERO_asb1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/home/mspitschan/logs';
params.jobName          = params.subjectName;
params.numRuns          = 9; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_asb1 - 060816 - MaxLMSCRF
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_asb1/060816';
params.subjectName      = 'HERO_asb1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/home/mspitschan/logs';
params.jobName          = params.subjectName;
params.numRuns          = 9; % Number of BOLD runs
create_preprocessing_scripts(params);


%% HERO_aso1 - 053116 - MaxMelCRF
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_aso1/053116';
params.subjectName      = 'HERO_aso1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/home/mspitschan/logs';
params.jobName          = params.subjectName;
params.numRuns          = 9; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_aso1 - 060116 - MaxLMSCRF
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_aso1/060116';
params.subjectName      = 'HERO_aso1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/home/mspitschan/logs';
params.jobName          = params.subjectName;
params.numRuns          = 9; % Number of BOLD runs
create_preprocessing_scripts(params);


%% HERO_gka1 - 060216 - MaxMelCRF
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_gka1/060216';
params.subjectName      = 'HERO_gka1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/home/mspitschan/logs';
params.jobName          = params.subjectName;
params.numRuns          = 9; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_gka1 - 060616 - MaxLMSCRF
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_gka1/060616';
params.subjectName      = 'HERO_gka1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/home/mspitschan/logs';
params.jobName          = params.subjectName;
params.numRuns          = 10; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_mxs1 - 060916 - MaxMelCRF (1)
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_mxs1/060916';
params.subjectName      = 'HERO_mxs1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/home/mspitschan/logs';
params.jobName          = params.subjectName;
params.numRuns          = 5; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_mxs1 - 061016_Mel - MaxMelCRF (2)
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_mxs1/061016_Mel';
params.subjectName      = 'HERO_mxs1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/home/mspitschan/logs';
params.jobName          = params.subjectName;
params.numRuns          = 4; % Number of BOLD runs
create_preprocessing_scripts(params);

%% HERO_mxs1 - 062816 - MaxLMSCRF
params = params0;
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_mxs1/040816';
params.subjectName      = 'HERO_mxs1_MaxMel';
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/home/mspitschan/logs';
params.jobName          = params.subjectName;
params.numRuns          = 9; % Number of BOLD runs
create_preprocessing_scripts(params);