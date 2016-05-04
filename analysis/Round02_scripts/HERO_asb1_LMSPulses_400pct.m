%%%%%%%% Analysis for HERO_asb1 LMSPulses_400pct %%%%%%%%%%

%% inputs
results_dir =  '/data/jag/MELA/MelanopsinMR/Results';
data_dir = '/data/jag/MELA/MelanopsinMR'; %Upenn cluster default path
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects'; %Upenn cluster default path
subject_name = 'HERO_asb1_MaxMel';
subj_name = 'HERO_asb1';
session_date = '040716';
condition = 'LMSPulses_400pct';
numOfRuns =  10 ;
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

%% Step 2: first level stat

MelanopsinMR_FeatStatAnalysis (results_dir, data_dir, subj_name,session_date,condition, numOfRuns, funcs, SUBJECTS_DIR)
% run the sh scripts and proceed to step 3

%% Step 3: post FEAT stat
runNums = 1:numOfRuns;

MelanopsinMR_PostFeatAnalysis (results_dir, data_dir, SUBJECTS_DIR, ...
    subject_name, subj_name, session_date, condition, runNums,funcs, project_template, project_copes)

%move the relevant results to dropbox