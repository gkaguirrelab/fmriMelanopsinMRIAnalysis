% New Master from MS
params.resultsDir =  '/data/jag/MELA/MelanopsinMR/results';
params.logDir = '/data/jag/MELA/MelanopsinMR/logs';
params.dataDir = '/data/jag/MELA/MelanopsinMR';

% Create preprocessing scripts
fmriMelanopsinMRIAnalysis_createPreprocessingScripts(params);

% Create preprocessing scripts
MelanopsinMR_Analysis_400PctData;
MelanopsinMR_Analysis_CRFData;
MelanopsinMR_Analysis_SplatterControlData;

% Make anatomical templates
MelanopsinMR_MakeTemplates;

% Derive the HRFs
MelanopsinMR_HRFDerive;
MelanopsinMR_HRFPlot;
