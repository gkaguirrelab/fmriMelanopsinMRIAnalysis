function MelanopsinMR_PostFeatAnalysis (results_dir, data_dir, SUBJECTS_DIR, subject_name,subj_name,session_date, condition, runNums,funcs, templ2subj, psc_cope)

% 3rd step for MelanopsinMR data processing. Follows:
% MelanopsinMR_Preprocessing, MelanopsinMR_FeatStatAnalysis.
%
% Global Input arguments:
% results_dir :  general path where all results for this project are saved. Specific
% subfolders are created during each step. Note that intermediate results
% are saved in specific paths within the data_dir.
% data_dir : path to the data directory. Raw data and
% intermediate results are store in
% <data_dir>/<subject_name>/<session_date>/ (session_dir)
% SUBJECTS_DIR : path tho the Freesurfer subjects directory.
% subject_name : name of the Freesurfer subject corrisponding to the
% current subject.
% subj_name : name of the current subject
% condition : 'LMSPulses_400pct' or 'MelPulses_400Pct'
% runNums : list of number of runs included in the analysis.
% funcs : list of names of the FEAT stat result folder (e.g. FUNC.feat) (must be consistent among
% runs) (all FEATstat folder must live within their own bold directory).

% Local input arguments
% where possible, local input arguments are hard coded according to
% pre-registration specifics.


%% Initialize

session_dir = fullfile(data_dir, subj_name,session_date);
output_dir = fullfile( results_dir, condition, subj_name, session_date);
if ~exist (output_dir, 'dir')
    mkdir (output_dir);
end


%% Extract Chisquare and p-values using Fisher's method, save out statistical maps in output_dir.
% local inputs
Fisher_thresh = 0.05 ;  % hardcoded according to preregistration document

% convert F values to p values
for ii = 1:length(funcs)
    func = funcs{ii}; 
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
end
% Do the Fisher's combined probability test
for ii = 1:length(funcs)
    func = funcs{ii}; 
    fisher_combined_prob_test(session_dir,subject_name, subj_name, condition,runNums,func,Fisher_thresh,SUBJECTS_DIR,true);
end


%% FIR Analysis: Project template to subject
if templ2subject %needs to be done just one time
% local inputs 
hemis = {...
        'lh'...
        'rh'...
        };

templ2subject (session_dir, subject_name, SUBJECTS_DIR, hemis)
end

%% FIR Analysis: psc_cope

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




