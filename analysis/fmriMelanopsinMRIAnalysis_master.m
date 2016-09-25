% New Master from MS
params.resultsDir =  '/data/jag/MELA/MelanopsinMR/results';
params.logDir = '/data/jag/MELA/MelanopsinMR/logs';
params.dataDir = '/data/jag/MELA/MelanopsinMR';
params.anatTemplateDir = '/data/jag/MELA/anat_templates';

% Create preprocessing scripts
fmriMelanopsinMRIAnalysis_createPreprocessingScripts(params);

% Make anatomical templates
fmriMelanopsinMRIAnalysis_makeAnatTemplates(params);

% Derive the HRFs
fmriMelanopsinMRIAnalysis_deriveHRF(params);
fmriMelanopsinMRIAnalysis_plotHRF(params);
