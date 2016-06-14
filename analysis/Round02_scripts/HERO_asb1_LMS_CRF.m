%%%%%%%% Analysis for HERO_asb1 LMS_CFR %%%%%%%%%%

%% inputs
results_dir =  '/data/jag/MELA/MelanopsinMR/Results';
data_dir = '/data/jag/MELA/MelanopsinMR'; %Upenn cluster default path
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects'; %Upenn cluster default path
subject_name = 'HERO_asb1_MaxMel';
subj_name = 'HERO_asb1';
session_date = '060816';
condition = 'LMS_CFR';
numOfRuns =  9 ;
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