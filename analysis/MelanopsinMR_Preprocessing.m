function MelanopsinMR_Preprocessing (results_dir, data_dir, SUBJECTS_DIR, subject_name, subj_name, session_date, condition, numRuns, reconall)

% 1st step for MelanopsinMR data processing. Preceeds:
% MelanopsinMR_Preprocessing, MelanopsinMR_PostFeatStatAnalysis.
% Produces a LOG file.
%
% Global Input arguments:
% 
% results_dir :  general path where all results for this project are saved. Specific
% subfolders are created during each step. Note that intermediate results
% are saved in specific paths within the data_dir.
% 
% data_dir : path to the data directory. Raw data and
% intermediate results are store in
% <data_dir>/<subject_name>/<session_date>/ (session_dir)
% 
% SUBJECTS_DIR : path tho the Freesurfer subjects directory.
% 
% subject_name : name of the Freesurfer subject corrisponding to the
% current subject.
%
% subj_name : name of the current subject
% 
% runNums : list of number of runs in current session
% 
% Local input arguments:
% where possible, local input arguments are hard coded according to
% pre-registration documents.
%
%%%%%%%%%
% Usage:
% 
% results_dir =  '/some/path/ideally/on/dropbox/' ;
% data_dir = '/data/jag/MELA/'; %Upenn cluster default path
% SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects'; %Upenn cluster default path
% subj_name = 'HERO_xxx1';
% session_date = 'mmddyy';
% condition = 'MelPulses_400pct';
% nunRums =  12 ;
% MelanopsinMR_FeatStatAnalysis (results_dir, data_dir, SUBJECTS_DIR, subj_name,session_date,numRuns)
%
%%%%%%%%%
%% Initialize analysis
session_dir = fullfile(data_dir, subj_name,session_date);
output_dir = fullfile( results_dir, condition, subj_name, session_date);
if ~exist (output_dir, 'dir')
    mkdir (output_dir);
end
if ~exist (fullfile(output_dir, 'LOGS'),'dir')
    mkdir (fullfile(output_dir, 'LOGS'));
end
formatOut = 'mmddyy_HH.MM.SS';
timestamp = datestr((datetime('now')), formatOut);
diary (fullfile(output_dir, 'LOGS', [subj_name '_' condition '_Preprocessing_' timestamp '_LOG.txt']));
diary ('on')
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Preprocessing for %s , %s, %s ~~~~~~~~~~~~~~~~~~~\n', subj_name, session_date, condition);
time = datetime
results_dir
data_dir
SUBJECTS_DIR 
subject_name
subj_name
session_date 
condition
numRuns
%% Create preprocessing scripts
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Creating preprocessing scripts ~~~~~~~~~~~~~~~~~~~\n');
outDir = fullfile(session_dir,'shell_scripts', subj_name);
if ~exist(outDir,'dir')
    mkdir(outDir);
end
logDir = fullfile(data_dir, 'LOGS');
if ~exist(logDir,'dir')
    mkdir(logDir);
end
fprintf ('\nParameters: \n');
job_name = [subj_name '_' session_date]; 
slicetiming = 1
reconall
B0 = 0
filtType = 'high'
lowHz = 0.01
highHz = 0.10
physio = 1
motion = 1
task = 0
localWM = 1
anat = 1
amem = 20
fmem = 50

create_preprocessing_scripts(session_dir,subject_name,outDir, ...
    logDir,job_name,numRuns,reconall,slicetiming,B0,filtType, ...
    lowHz,highHz,physio,motion,task,localWM,anat,amem,fmem)
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Done! ~~~~~~~~~~~~~~~~~~~\n');

%% Start Preprocessing
fprintf (['\n~~~~~~~~~~~~~~~~~~~ You can now start preprocessing using the script submit_' job_name '_all.sh ~~~~~~~~~~~~~~~~~~~\n']);

diary ('off')
%%% TEST IF THIS WORKS
% system(['sh submit_' job_name '_all.sh'])  %must be on chead to run this!

