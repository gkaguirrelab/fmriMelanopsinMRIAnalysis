function fmriMelanopsinMRIAnalysis_deriveHRF(inputParams)

% Set parameters common to all analyses
params0.roiType     = 'V1';
params0.func        = 'wdrf.tf';
params0.eccRange    = [2.5 32];

%% HERO_asb1
params              = params0;
params.subjDir      = fullfile(inputParams.dataDir, 'HERO_asb1/');
HRF = subjHRF(params);

%% HERO_aso1
params              = params0;
params.subjDir      = fullfile(inputParams.dataDir, 'HERO_aso1/');
HRF = subjHRF(params);

%% HERO_gka1
params              = params0;
params.subjDir      = fullfile(inputParams.dataDir, 'HERO_gka1/');
HRF = subjHRF(params);

%% HERO_mxs1
params              = params0;
params.subjDir      = fullfile(inputParams.dataDir, 'HERO_mxs1/');
HRF = subjHRF(params);