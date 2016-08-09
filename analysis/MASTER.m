%% MelanopsinMR master script - v.2

% Dataset and project description goes here


%% Dataset variables
% global paths
results_dir =  '/data/jag/MELA/MelanopsinMR/Results';
data_dir = '/data/jag/MELA/MelanopsinMR'; %Upenn cluster default path
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects'; %Upenn cluster default path
if ~exist (results_dir, 'dir')
    mkdir (results_dir);
end
% subject names
subjNames = { ...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1' ...
    };

% freesurfer subject names
subject_names = { ...
    'HERO_asb1_MaxMel' ...
    'HERO_aso1_MaxMel' ...
    'HERO_gka1_3T' ...
    'HERO_mxs1_MaxMel' ...
    };

% 400pct MaxMel sessions
sessionsMEL400 = { ...
    '032416' ...
    '032516' ...
    '033116' ...
    '040616' ...
    };

% 400pct MaxLMS sessions
sessionsLMS400 = { ...
    '040716' ...
    '033016' ...
    '040116' ...
    '040816' ...
    };

% Splatter Control CRF
sessionsSplatterCRF = { ...
    '051016' ...
    '042916' ...
    '050616' ...
    '050916' ...
    };

% Mel Pulses CRF
sessionsMELCRF = { ...
    '060716' ...
    '053116' ...
    '060216' ...
    {'060916' '061016'} ...  %%%% for HERO_mxs1 this condition was acquired in 2 different sessions
    };

% LMS Pulses CRF
sessionsLMSCRF = { ...
    '060816' ...
    '060116' ...
    '060616' ...
    '062816' ...
    };


%% Analysis variables
% session types (or conditions)
conditions = {...
    'MelPulses400pct' ...
    'LMSPulses400pct' ...
    'SplatterControlCRF' ...
    'MelPulsesCRF' ...
    'LMSPulsesCRF' ...
    };
% hemispheres
hemis = {...
    'mh'...
    'lh'...
    'rh'...
    };
% ROIs
ROIs = {...
    'V1' ...
    'V2andV3'...
    'LGN'...
    };
% controls
controlsSplatter = { ...
    '_25pct'...
    '_50pct'...
    '_100pct'...
    '_195pct'...
    '_AttentionTask'...
    };

controlsCRF = {...
    '_25pct'...
    '_50pct'...
    '_100pct'...
    '_200pct'...
    '_400pct'...
    '_AttentionTask'...
    };
% directions
directions = { ...
    'Mel'
    'LMS'
    'AttentionTask'
    };

%% Setting up LOG File
% This section will create a log file in which all the following steps will
% be recorded as single entries, with their own timestamps, using Matlab's
% "diary" function. This log file appends any new instance at the end. To
% get a "clean" log, delete any previously existing log files and run the
% script from start to end once.
% Note that some functions called in the script (e.g.
% create_preprocessing_scripts) will create their own log files.

% set logfile path and name
diaryfile = fullfile(results_dir, 'MasterScriptLOG.txt');
% set timestamp format
formatOut = 'mmddyy_HH.MM.SS';


%% Getting the dataset ready for the analysis
% This section assumes that the analysis starts on the fMRI dataset as it is
% backed up on the DVDs; for every session, the following files and folders should be present:
% 1. DICOMS/  (containing sorted or unsorted .dcm files)
% 2. PulseOx/
% 3. Protocols/
% 4. MatFiles/
% 5. README.md 

% start logging
diary(diaryfile)
diary ('on')
timestamp = datestr((datetime('now')), formatOut);
fprintf ('\n\n~~~~~~~ Getting the dataset ready for the analysis - %s ~~~~~~~\n\n', timestamp);
tic;

% Before proceeding with the analysis, we make sure that every session
% contains the appropriate DICOM files.

% Firstly, we sort the DICOM files into Series folders:
for ss = 1:length(subjNames)
    sprintf ('Sorting DICOMs for subject %s \n', subjNames{ss});
    dicom_sort (fullfile(data_dir, subjNames{ss}, sessionsMEL400{ss}, 'DICOMS'));
    dicom_sort (fullfile(data_dir, subjNames{ss}, sessionsLMS400{ss}, 'DICOMS'));
    dicom_sort (fullfile(data_dir, subjNames{ss}, sessionsSplatterCRF{ss}, 'DICOMS'));
    dicom_sort (fullfile(data_dir, subjNames{ss}, sessionsMELCRF{ss}, 'DICOMS'));
    dicom_sort (fullfile(data_dir, subjNames{ss}, sessionsLMSCRF{ss}, 'DICOMS'));
end
fprintf ('All DICOMS are sorted.\n');

% In each session folder, we MANUALLY DELETE the incomplete DICOM series
% that resulted from acquisition errors during the session, as per
% information on the README.md file.
fprintf ('\n>>>> MANUALLY DELETE incomplete DICOM series from each session folder, as per information on the README.md file <<<<<\n' )


% We acquired a single T1 series from each subject, during the MelPulses400
% session (i.e. each subject's first session). For each subject, we copy
% the MPRAGE DICOM series from the Mel400 session in the other sessions DICOM
% folders.
for ss = 1:length(subjNames)
    fprintf ('Copying MPRAGE DICOM files for subject %s \n', subjNames{ss});
    copyfile(fullfile(data_dir, subjNames{ss}, sessionsMEL400{ss}, 'DICOMS','MPRAGE'), ...
        fullfile(data_dir, subjNames{ss}, sessionsLMS400{ss}, 'DICOMS', 'MPRAGE'));
    copyfile(fullfile(data_dir, subjNames{ss}, sessionsMEL400{ss}, 'DICOMS','MPRAGE'), ...
        fullfile(data_dir, subjNames{ss}, sessionsSplatterCRF{ss}, 'DICOMS', 'MPRAGE'));
    copyfile(fullfile(data_dir, subjNames{ss}, sessionsMEL400{ss}, 'DICOMS','MPRAGE'), ...
        fullfile(data_dir, subjNames{ss}, sessionsMELCRF{ss}, 'DICOMS', 'MPRAGE'));
    copyfile(fullfile(data_dir, subjNames{ss}, sessionsMEL400{ss}, 'DICOMS','MPRAGE'), ...
        fullfile(data_dir, subjNames{ss}, sessionsLMSCRF{ss}, 'DICOMS', 'MPRAGE'));
end
fprintf ('All MPRAGE folders copied.\n');
fprintf ('\n\nThe dataset is now ready for the analysis.\n')
toc

% stop logging
diary ('off')

%% Preprocessing
% start logging
diary(diaryfile)
diary ('on')
timestamp = datestr((datetime('now')), formatOut);
fprintf ('\n\n~~~~~~~ Preprocessing - %s ~~~~~~~\n\n', timestamp);
tic;

% Variables for preprocessing (intentionally with no ; for displaying
% purposes)
fprintf ('\nGeneral parameters for MRklar preprocessing: \n');
slicetiming = 0 
reconall = 1  % change to zero if the dataset was already run thorugh freesurfer reconall
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

for ss = 1:length(subjNames)
    subject_name = subject_names{ss};
    sessions = { ...
        sessionsMEL400{ss} ...
        sessionsLMS400{ss} ...
        sessionsSplatterCRF400{ss} ...
        sessionsMELCRF{ss} ...
        sessionsLMSCRF{ss} ...
        };
    for nn = 1:length(sessions);
        session_dir  = fullfile(data_dir, subjNames{ss}, sessions{nn});
        % Convert the DICOM to NIFTI and count how
        % many bold runs are in each session. Even though the preprocessing
        % scripts have an embedded conversion function, we do that now to
        % avoid to feed the number of bold runs for each session as a
        % variable beforehand.
        fprintf ('Converting DICOMS to NIFTI for subject %s, session %s \n', subjNames{ss}, sessions{nn});
        sort_nifti (session_dir);
        b = find_bold(session_dir);
        numRuns = length(b);
        fprintf ('>> %d BOLD run found./n', numRuns)
        % Create preprocessing scripts for this session
        job_name = [subjNames{ss} '_' sessions{nn}];
        outDir = fullfile(session_dir,'shell_scripts', subj_name);
        if ~exist(outDir,'dir')
            mkdir(outDir);
        end
        logDir = fullfile(data_dir, 'LOGS');
        if ~exist(logDir,'dir')
            mkdir(logDir);
        end
        fprintf ('Creating preprocessing scripts for subject %s, session %s \n', subjNames{ss}, sessions{nn});
        create_preprocessing_scripts(session_dir,subject_name,outDir, ...
            logDir,job_name,numRuns,reconall,slicetiming,B0,filtType, ...
            lowHz,highHz,physio,motion,task,localWM,anat,amem,fmem)
        fprintf ('>> Done\n');
        % Launch preprocessing scripts using a system command 
        fprintf ('Launching preprocessing script for subject %s, session %s \n', subjNames{ss}, sessions{nn});
        system(sprintf(['sh ' outDir '/' 'submit_' job_name '_all.sh']));
        fprintf ('>> Done\n');
    end    
end
fprintf ('\n\nAll preprocessing script have been submitted. Wait for them to complete before moving on with this script\n')
toc

%stop logging
diary ('off')
