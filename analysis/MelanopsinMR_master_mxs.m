% New Master from MS
results_dir =  '/data/jag/MELA/MelanopsinMR/Results';
data_dir = '/data/jag/MELA/MelanopsinMR'; %Upenn cluster default path

% Create preprocessing scripts
MelanopsinMR_Analysis_400PctData;
MelanopsinMR_Analysis_CRFData;
MelanopsinMR_Analysis_SplatterControlData;

% Make anatomical templates
MelanopsinMR_MakeTemplates;

% Derive the HRFs
MelanopsinMR_HRFDerive;
MelanopsinMR_HRFPlot;
