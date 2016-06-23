%%%%%%%% Post FEAT stat for HERO_mxs1 Mel CRF (sessions 060916 and 061016_Mel).
%%%%%%%% Note that to run this script the BOLD runs from 061016_Mel have
%%%%%%%% been copied in 060916 AFTER the first 2 steps of processing.


%% inputs
results_dir =  '/data/jag/MELA/MelanopsinMR/Results';
data_dir = '/data/jag/MELA/MelanopsinMR'; %Upenn cluster default path
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects'; %Upenn cluster default path
subject_name = 'HERO_mxs1_MaxMel';
subj_name = 'HERO_mxs1';
session_date = '060916';
condition = 'MaxMelCRF';
numOfRuns =  9 ;
funcs = { ...
'wdrf.tf' ...
's5.wdrf.tf' ...
};
proj_template = true;
proj_copes = true;

%% Post FEAT Stat
runNums = 1:numOfRuns;

MelanopsinMR_PostFeatAnalysis (results_dir, data_dir, SUBJECTS_DIR, ...
    subject_name, subj_name, session_date, condition, runNums,funcs, proj_template, proj_copes)

%move the relevant results to dropbox