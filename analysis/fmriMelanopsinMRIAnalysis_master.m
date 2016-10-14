% fmriMelanopsinMRIAnalysis_master.m
%
% % 9/26/2016     ms      Homogenized comments and script documentation.

%% Define parameters that we need for the various components
params.resultsDir =  '/data/jag/MELA/MelanopsinMR/results';
params.logDir = '/data/jag/MELA/MelanopsinMR/logs';
params.dataDir = '/data/jag/MELA/MelanopsinMR';
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
fmriMelanopsinMRIAnalysis_fitCRFData(params);