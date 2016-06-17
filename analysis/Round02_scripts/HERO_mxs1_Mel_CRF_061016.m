%%%%%%%% Analysis for HERO_mxs1 Mel_CRF(061016) %%%%%%%%%%

%% inputs
results_dir =  '/data/jag/MELA/MelanopsinMR/Results';
data_dir = '/data/jag/MELA/MelanopsinMR'; %Upenn cluster default path
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects'; %Upenn cluster default path
subject_name = 'HERO_mxs1_MaxMel';
subj_name = 'HERO_mxs1';
session_date = '061016_Mel';
condition = 'MaxMelCRF';
numOfRuns =  4 ;
reconall = 0;  %already done
funcs = { ...
'wdrf.tf' ...
's5.wdrf.tf' ...
};
proj_template = true;
proj_copes = true;


%% Step 1: preprocessing

MelanopsinMR_Preprocessing (results_dir, data_dir, SUBJECTS_DIR, ...
    subject_name, subj_name, session_date, condition, numOfRuns, reconall)

% run the sh script and proceed to step 2

%% Step 2: first level stat

MelanopsinMR_FeatStatAnalysis (results_dir, data_dir, subj_name,session_date,condition, numOfRuns, funcs, SUBJECTS_DIR)
% run the sh scripts and proceed to step 3
