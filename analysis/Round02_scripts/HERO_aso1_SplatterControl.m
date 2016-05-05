%%%%%%%% Analysis for HERO_aso1 SplatterControl %%%%%%%%%%

%% inputs
results_dir =  '/data/jag/MELA/MelanopsinMR/Results';
data_dir = '/data/jag/MELA/MelanopsinMR'; %Upenn cluster default path
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects'; %Upenn cluster default path
subject_name = 'HERO_aso1_MaxMel';
subj_name = 'HERO_aso1';
session_date = '042916';
condition = 'SplatterControl';
numOfRuns =  12 ;
reconall = 0;  %already done
funcs = { ...
'wdrf.tf' ...
's5.wdrf.tf' ...
};
project_template = true;
project_copes = true;


%% Step 1: preprocessing

MelanopsinMR_Preprocessing (results_dir, data_dir, SUBJECTS_DIR, ...
    subject_name, subj_name, session_date, condition, numOfRuns, reconall)

% run the sh script and proceed to step 2