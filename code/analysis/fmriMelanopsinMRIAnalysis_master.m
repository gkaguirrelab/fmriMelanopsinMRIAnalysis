% fmriMelanopsinMRIAnalysis_master.m
%
% % 9/26/2016     ms      Homogenized comments and script documentation.

%% Define parameters that we need for the various components
params.resultsDir =  '/data/jag/MELA/RERUN_MelanopsinMR/results';
params.logDir = '/data/jag/MELA/RERUN_MelanopsinMR/logs';
params.dataDir = '/data/jag/MELA/RERUN_MelanopsinMR';
params.anatTemplateDir = '/data/jag/MELA/anat_templates';

%% Create preprocessing scripts
fmriMelanopsinMRIAnalysis_createPreprocessingScripts(params);

%% Run the preprocessing scripts
% <!> Note that this is typically done from a command line.

%% Make anatomical templates
fmriMelanopsinMRIAnalysis_makeAnatTemplates(params);

%% Project anatomical templates
fmriMelanopsinMRIAnalysis_projectAnatTemplatesToFunc(params);

%% Derive the HRFs
fmriMelanopsinMRIAnalysis_deriveHRF(params);
fmriMelanopsinMRIAnalysis_plotHRF(params);


%% Derive the significant voxels
fmriMelanopsinMRIAnalysis_fit400PctData(params);
fmriMelanopsinMRIAnalysis_mergeMaps(params);

%% Assemble V1 time series for the CRF data
fmriMelanopsinMRIAnalysis_makeAllCRFPackets(params);


%% Rod control data - Add the subject's HRF
% Make this a function
fmriMelanopsinMRIAnalysis_CopyHRFFiles(fullfile(params.dataDir, 'HERO_asb1', '051016'), fullfile(params.dataDir, 'HERO_asb1', '101916'));
fmriMelanopsinMRIAnalysis_CopyHRFFiles(fullfile(params.dataDir, 'HERO_gka1', '050616'), fullfile(params.dataDir, 'HERO_gka1', '101916'));
fmriMelanopsinMRIAnalysis_CopyHRFFiles(fullfile(params.dataDir, 'HERO_gka1', '050616'), fullfile(params.dataDir, 'HERO_gka1', '102416'));
fmriMelanopsinMRIAnalysis_CopyHRFFiles(fullfile(params.dataDir, 'HERO_mxs1', '050916'), fullfile(params.dataDir, 'HERO_mxs1', '101916'));
fmriMelanopsinMRIAnalysis_CopyHRFFiles(fullfile(params.dataDir, 'HERO_mxs1', '050916'), fullfile(params.dataDir, 'HERO_mxs1', '102416'));