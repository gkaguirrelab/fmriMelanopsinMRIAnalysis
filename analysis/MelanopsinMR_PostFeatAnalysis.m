function MelanopsinMR_PostFeatAnalysis (results_dir, data_dir, SUBJECTS_DIR, subject_name,subj_name,session_date, condition, runNums,funcs, project_template, project_copes)

% 3rd step for MelanopsinMR data processing. Follows:
% MelanopsinMR_Preprocessing, MelanopsinMR_FeatStatAnalysis.
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
% condition : 'LMSPulses_400pct' or 'MelPulses_400pct'
% 
% runNums : list of number of runs included in the analysis (i.e. valid runs).
% 
% funcs : list of names of the FEAT stat result folder (e.g. FUNC.feat) (must be consistent among
% runs) (all FEATstat folders must live within their own bold directory).

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
% subject_name = 'HERO_xxx1_MaxMel';
% subj_name = 'HERO_xxx1';
% session_date = 'mmddyy';
% condition = 'MelPulses_400pct';
% runNums =  1:12 ;
% funcs = {...
%     'FIR_raw' ... %raw data needs to be in position 1
%     'FIR_5mm' ... %5mm data needs to be in position 2
%     };
% project_template = true;
% project_copes = true;
%
% MelanopsinMR_PostFeatAnalysis (results_dir, data_dir, SUBJECTS_DIR, subject_name,subj_name,session_date, condition, runNums,funcs, project_template, project_copes)
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
diary (fullfile(output_dir, 'LOGS', [subj_name '_' condition '_PostFEATAnalyis_' timestamp '_LOG.txt']));
diary ('on')
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Post FEAT analysis for %s , %s, %s ~~~~~~~~~~~~~~~~~~~\n', subj_name, session_date, condition);
time = datetime
results_dir
data_dir
SUBJECTS_DIR 
subject_name 
subj_name 
session_date 
condition 
runNums 
funcs 
project_template
project_copes 


% %% Extract Chisquare and p-values using Fisher's method, save out statistical maps in output_dir.
% fprintf ('\n ~~~~~~~~~~~~~~~~~~~ Starting Fishers analysis ~~~~~~~~~~~~~~~~~~~\n');
% % local inputs
% Fisher_thresh = 0.05  % hardcoded according to preregistration document
% % convert F values to p values
% func = funcs{2};
% convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% % Do the Fisher's combined probability test
% func = funcs{2};
% fisher_combined_prob_test(output_dir,session_dir,subject_name, subj_name, condition,runNums,func,Fisher_thresh,SUBJECTS_DIR,true);
% 
% fprintf ('\n~~~~~~~~~~~~~~~~~~~ Fishers analysis complete! ~~~~~~~~~~~~~~~~~~~\n');

%% FIR Analysis: Project template to subject
% Requires that the subject has been registered using:
% mri_cvs_register --mov <subject_name> --template cvs_avg35_inMNI152

if project_template %needs to be done just one time
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Projecting template to subject space... ~~~~~~~~~~~~~~~~~~~ \n');
% local inputs 
hemis = {...
        'lh'...
        'rh'...
        };
%project template
templ2subject (session_dir, subject_name, SUBJECTS_DIR, hemis)
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Projection to subject space complete! ~~~~~~~~~~~~~~~~~~~ \n');
end

%% FIR Analysis: project the copes, get the means, save figures and csv files
% local inputs
hemis = {...
    'mh'...
    'lh'...
    'rh'...
    };
ROIs = {...
    'V1' ...
    'V2andV3'...
    'LGN'...
    };
copeNames = {...
    'Sec00' ...
    'Sec01' ...
    'Sec02' ...
    'Sec03' ...
    'Sec04' ...
    'Sec05' ...
    'Sec06' ...
    'Sec07' ...
    'Sec08' ...
    'Sec09' ...
    'Sec10' ...
    'Sec11' ...
    'Sec12' ...
    'Sec13' ...
    };
funcs = funcs (1);
% project copes
if project_copes %needs to be run just one time
    fprintf ('\n~~~~~~~~~~~~~~~~~~~ Projecting copes... ~~~~~~~~~~~~~~~~~~~\n');
    project_copes(session_dir, subject_name, copeNames, hemis, ROIs, funcs)
    fprintf ('\n~~~~~~~~~~~~~~~~~~~ Cope projection complete! ~~~~~~~~~~~~~~~~~~~\n');
end

% Get means, plot them and save them as a csv file
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Calculating, plotting and saving FIR means... ~~~~~~~~~~~~~~~~~~~\n');
FIR_assemble(session_dir, subject_name, subj_name, output_dir, SUBJECTS_DIR, copeNames, runNums, hemis, ROIs, funcs, condition)
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Post FEAT Analysis complete for %s, %s, %s ~~~~~~~~~~~~~~~~~~~\n', subj_name, session_date, condition);
time = datetime
diary ('off')


